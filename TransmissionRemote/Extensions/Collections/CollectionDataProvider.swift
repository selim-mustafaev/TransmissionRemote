import Foundation
import DifferenceKit

public protocol CollectionDataProvider {
	associatedtype T
	
	func numberOfSections() -> Int
	func numberOfItems(in section: Int) -> Int
	func item(at indexPath: IndexPath) -> T?
	
	func updateItem(at indexPath: IndexPath, value: T)
    func setSortPredicates(_ predicates: [SortPredicate<T>]) -> StagedChangeset<[T]>
    func setFilterPredicate(_ predicate: @escaping (T) -> Bool) -> StagedChangeset<[T]>
    func removeFilterPredicate() -> StagedChangeset<[T]>
    func setData(_ array: [T]) -> StagedChangeset<[T]>
	func updateFilteredItems()
	func updateData(_ data: [T])
}
