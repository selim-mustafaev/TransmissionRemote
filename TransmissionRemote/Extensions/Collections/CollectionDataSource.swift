import Foundation
import Cocoa
import DeepDiff

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
		
		//print("viewFor tableColumn row: \(row), id: \(id.rawValue)")
		
//        var cell: NSView? = self.cells[row]?[id]
//        if cell == nil {
//            cell = tableView.makeView(withIdentifier: id, owner: nil)
//
//            if let cell = cell {
//                if self.cells[row] != nil {
//                    self.cells[row]?[id] = cell
//                } else {
//                    self.cells[row] = [id: cell]
//                }
//            }
//        }
		
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
        self.apply(changes: changes)
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
        self.apply(changes: changes)
    }
    
    public func removeFilterPredicate() {
        let changes = self.provider.removeFilterPredicate()
        self.apply(changes: changes)
    }
    
    public func getSelectedItems() -> [Provider.T] {
        return self.tableView.selectedRowIndexes.map { self.provider.item(at: IndexPath(item: $0, section: 0) ) }.compactMap { $0 }
    }
    
	@discardableResult
    public func setData(_ array: [Provider.T]) -> [[Change<Provider.T>]]  {
        let changes = self.provider.setData([array])
        self.apply(changes: changes)
		return changes
    }
    
    public func apply(changes: [[Change<Provider.T>]]) {
        if let firstChanges = changes.first {
			if firstChanges.count == 0 {
				return
			}
			
            let inserts = firstChanges.compactMap { $0.insert }
            let replaces = firstChanges.compactMap { $0.replace }
            let moves = firstChanges.compactMap { $0.move }
            let deletes = firstChanges.compactMap { $0.delete }
            
            self.tableView.beginUpdates()
            
			if deletes.count > 0 { self.tableView.removeRows(at: IndexSet(deletes.map { $0.index })) }
			if inserts.count > 0 { self.tableView.insertRows(at: IndexSet(inserts.map { $0.index })) }
			if moves.count > 0 { moves.forEach { self.tableView.moveRow(at: $0.fromIndex, to: $0.toIndex) } }
			if replaces.count > 0 { self.tableView.reloadData(forRowIndexes: IndexSet(replaces.map { $0.index }), columnIndexes: IndexSet(0..<tableView.tableColumns.count)) }
            
            self.tableView.endUpdates()
        }
    }
}
