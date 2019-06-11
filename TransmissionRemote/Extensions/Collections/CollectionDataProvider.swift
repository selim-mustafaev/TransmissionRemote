import Foundation
import DeepDiff

public protocol CollectionDataProvider {
	associatedtype T
	
	func numberOfSections() -> Int
	func numberOfItems(in section: Int) -> Int
	func item(at indexPath: IndexPath) -> T?
	
	func updateItem(at indexPath: IndexPath, value: T)
    func setSortPredicates(_ predicates: [SortPredicate<T>]) -> [[Change<T>]]
    func setFilterPredicate(_ predicate: @escaping (T) -> Bool) -> [[Change<T>]]
    func removeFilterPredicate() -> [[Change<T>]]
    func setData(_ array: [[T]]) -> [[Change<T>]]
}
