import Foundation
import Cocoa
import DeepDiff
import TransmissionRemoteCore

public class ArrayDataProvider<T>: CollectionDataProvider where T: Mergeable & DiffAware & AnyObject {
    
	// MARK: - Internal Properties
    var items: [[T]] = []
    var filteredItems: [[T]] = []
    
    var sortPredicates: [SortPredicate<T>] = []
    var filterPredicate: ((T) -> Bool)?
	
	// MARK: - Lifecycle
	init(array: [[T]]) {
		self.items = array
        self.filteredItems = self.items
	}
	
	// MARK: - CollectionDataProvider
	public func numberOfSections() -> Int {
		return filteredItems.count
	}
	
	public func numberOfItems(in section: Int) -> Int {
		guard section >= 0 && section < filteredItems.count else {
			return 0
		}
		return filteredItems[section].count
	}
	
	public func item(at indexPath: IndexPath) -> T? {
		guard indexPath.section >= 0 &&
			indexPath.section < filteredItems.count &&
			indexPath.item >= 0 &&
			indexPath.item < filteredItems[indexPath.section].count else
		{
			return nil
		}
		return filteredItems[indexPath.section][indexPath.item]
	}
	
	public func updateItem(at indexPath: IndexPath, value: T) {
		guard indexPath.section >= 0 &&
			indexPath.section < filteredItems.count &&
			indexPath.item >= 0 &&
			indexPath.item < filteredItems[indexPath.section].count else
		{
			return
		}
		filteredItems[indexPath.section][indexPath.item] = value
	}
    
    public func setSortPredicates(_ predicates: [SortPredicate<T>]) -> [[Change<T>]] {
        self.sortPredicates = predicates
        return self.updateFilteredItems()
    }
    
    public func setFilterPredicate(_ predicate: @escaping (T) -> Bool) -> [[Change<T>]] {
        self.filterPredicate = predicate
        return self.updateFilteredItems()
    }
    
    public func removeFilterPredicate() -> [[Change<T>]] {
        self.filterPredicate = nil
        return self.updateFilteredItems()
    }
    
    public func setData(_ array: [[T]]) -> [[Change<T>]] {
        self.items = array
        return self.updateFilteredItems()
    }
    
    private func updateFilteredItems() -> [[Change<T>]] {
        var processed: [[T]] = []
        if let predicate = self.filterPredicate {
            processed = self.items.map { $0.filter(predicate) }
        } else {
            processed = self.items
        }
        
        if self.sortPredicates.count > 0 {
            processed = processed.map { $0.sorted(using: self.sortPredicates) }
        }
        
        let wf = WagnerFischer<T>(reduceMove: false)
        var changes: [[Change<T>]] = []
        for index in self.filteredItems.indices {
            let change = wf.diff(old: self.filteredItems[index], new: processed[index])
            changes.append(change)
        }
        self.filteredItems = processed
        return changes
    }
}
