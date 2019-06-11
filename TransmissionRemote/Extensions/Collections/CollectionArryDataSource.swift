import Foundation
import Cocoa
import DeepDiff

open class CollectionArrayDataSource<T: Mergeable & AnyObject>: CollectionDataSource<ArrayDataProvider<T>>
{
	// MARK: - Lifecycle
	public convenience init(collectionView: NSTableView, array: [T]) {
		self.init(collectionView: collectionView, array: [array])
	}
	
	public init(collectionView: NSTableView, array: [[T]]) {
		let provider = ArrayDataProvider(array: array)
		super.init(tableView: collectionView, provider: provider)
	}
	
	// MARK: - Public Methods
	public func item(at indexPath: IndexPath) -> T? {
		return provider.item(at: indexPath)
	}
	
	public func updateItem(at indexPath: IndexPath, value: T) {
		provider.updateItem(at: indexPath, value: value)
	}

}
