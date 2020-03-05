import Foundation
import Cocoa
import DifferenceKit

open class CollectionDataSource<Provider: CollectionDataProvider>:
	NSObject,
	NSTableViewDataSource,
	NSTableViewDelegate
{
    public typealias SelectionChangedHandler = ([Int]) -> Void
    
	let provider: Provider
	let tableView: NSTableView
    var sortPredicates: [NSUserInterfaceItemIdentifier: SortPredicate<Provider.T>] = [:]
    var cells: [Int:[NSUserInterfaceItemIdentifier:NSView]] = [:]
    
    public var selectionChanged: SelectionChangedHandler?
	
	// MARK: - Lifecycle
	
	init(tableView: NSTableView, provider: Provider) {
		self.tableView = tableView
		self.provider = provider
		super.init()
		setUp()
	}
	
	func setUp() {
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	// MARK: - NSTableViewDataSource
	
	public func numberOfRows(in tableView: NSTableView) -> Int {
		return self.provider.numberOfItems(in: 0)
	}
	
	// MARK: - NSTableViewDelegate
	
	public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard let id = tableColumn?.identifier else { return nil }
		
		let cell = tableView.makeView(withIdentifier: id, owner: nil)
		if let configurableCell = cell as? ConfigurableCell<Provider.T>, let item = self.provider.item(at: IndexPath(item: row, section: 0)) {
			configurableCell.configure(with: item, at: id)
		}
		
		return cell
	}
    
    public func tableViewSelectionDidChange(_ notification: Notification) {
        self.selectionChanged?(Array(self.tableView.selectedRowIndexes))
    }
    
    public func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        let predicates = tableView.sortDescriptors.map { (descriptor: NSSortDescriptor) -> SortPredicate<Provider.T>? in
            if let name = descriptor.key, let predicate = self.sortPredicates[NSUserInterfaceItemIdentifier(rawValue: name)] {
                predicate.ascending = descriptor.ascending
                return predicate
            }
            
            return nil
        }.compactMap { $0 }

        let changes = self.provider.setSortPredicates(predicates)
        self.apply(changes: changes) { _ in self.provider.updateFilteredItems() }
    }
    
    public func setSortPredicates(_ functions: [NSUserInterfaceItemIdentifier: SortFunc<Provider.T>]) {
        self.sortPredicates.removeAll()
        for column in self.tableView.tableColumns {
            if let sortFunc = functions[column.identifier] {
                let descriptor = NSSortDescriptor(key: column.identifier.rawValue, ascending: true)
                column.sortDescriptorPrototype = descriptor
                self.sortPredicates[column.identifier] = SortPredicate(sortFunc: sortFunc)
            }
        }
    }
    
    public func setFilterPredicate(_ predicate: @escaping (Provider.T) -> Bool) {
        let changes = self.provider.setFilterPredicate(predicate)
        self.apply(changes: changes) { _ in self.provider.updateFilteredItems() }
    }
    
    public func removeFilterPredicate() {
        let changes = self.provider.removeFilterPredicate()
		self.apply(changes: changes) { _ in self.provider.updateFilteredItems() }
    }
    
    public func getSelectedItems() -> [Provider.T] {
        return self.tableView.selectedRowIndexes.map { self.provider.item(at: IndexPath(item: $0, section: 0) ) }.compactMap { $0 }
    }
    
	@discardableResult
    public func setData(_ array: [Provider.T]) -> StagedChangeset<[Provider.T]>  {
        let changes = self.provider.setData(array)
		
        self.apply(changes: changes) { data in
			//self.provider.updateFilteredItems()
			self.provider.updateData(data)
		}
		
		return changes
    }
    
	public func apply(changes: StagedChangeset<[Provider.T]>, _ updateData: ([Provider.T]) -> Void) {
		guard !changes.isEmpty else { return }
		self.tableView.reloadTable(using: changes, with: [], setData: updateData)
    }
}
