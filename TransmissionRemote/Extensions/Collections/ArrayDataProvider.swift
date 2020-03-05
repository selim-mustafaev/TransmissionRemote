import Foundation
import Cocoa
import DifferenceKit
import TransmissionRemoteCore

public class ArrayDataProvider<T>: CollectionDataProvider where T: Mergeable & AnyObject {
    
	// MARK: - Internal Properties
    var items: [T] = []
    var filteredItems: [T] = []
	var filteredItemsTemp: [T] = []
    
    var sortPredicates: [SortPredicate<T>] = []
    var filterPredicate: ((T) -> Bool)?
	
	// MARK: - Lifecycle
	init(array: [T]) {
		self.items = array
        self.filteredItems = self.items
	}
	
	// MARK: - CollectionDataProvider
	public func numberOfSections() -> Int {
		return 1
	}
	
	public func numberOfItems(in section: Int) -> Int {
		return filteredItems.count
	}
	
	public func item(at indexPath: IndexPath) -> T? {
		guard indexPath.item >= 0 && indexPath.item < filteredItems.count else
		{
			return nil
		}
		return filteredItems[indexPath.item]
	}
	
	public func updateItem(at indexPath: IndexPath, value: T) {
		guard indexPath.item >= 0 && indexPath.item < filteredItems.count else
		{
			return
		}
		filteredItems[indexPath.item] = value
	}
    
    public func setSortPredicates(_ predicates: [SortPredicate<T>]) -> StagedChangeset<[T]> {
        self.sortPredicates = predicates
        return self.calcChanges()
    }
    
    public func setFilterPredicate(_ predicate: @escaping (T) -> Bool) -> StagedChangeset<[T]> {
        self.filterPredicate = predicate
        return self.calcChanges()
    }
    
    public func removeFilterPredicate() -> StagedChangeset<[T]> {
        self.filterPredicate = nil
        return self.calcChanges()
    }
    
    public func setData(_ array: [T]) -> StagedChangeset<[T]> {
        self.items = array
        return self.calcChanges()
    }
    
    private func calcChanges() -> StagedChangeset<[T]> {
        var processed: [T] = []
        if let predicate = self.filterPredicate {
            processed = self.items.filter(predicate)
        } else {
            processed = self.items
        }
        
        if self.sortPredicates.count > 0 {
            processed = processed.sorted(using: self.sortPredicates)
        }
		
		let changes = StagedChangeset(source: self.filteredItems, target: processed)
        self.filteredItemsTemp = processed
        return changes
    }
	
	public func updateFilteredItems() {
		self.filteredItems = self.filteredItemsTemp
	}
	
	public func updateData(_ data: [T]) {
		self.filteredItems = data
	}
}
