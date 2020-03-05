import Foundation
import DifferenceKit

public protocol Mergeable: Differentiable {
    mutating func copy(from item: Self)
}

public extension Array where Element: Mergeable {
    mutating func merge(with array: Array<Element>) -> StagedChangeset<[Element]> {
		let changes = StagedChangeset(source: self, target: array)
		
		for changeset in changes {
			if changeset.elementInserted.count > 0 {
                changeset.elementInserted.forEach { self.insert(changeset.data[$0.element], at: $0.element) }
			}
			
			if changeset.elementUpdated.count > 0 {
				changeset.elementUpdated.forEach { self[$0.element].copy(from: changeset.data[$0.element]) }
			}
			
			if changeset.elementMoved.count > 0 {
				// TODO: Implement later
			}
			
			if changeset.elementDeleted.count > 0 {
				changeset.elementDeleted.forEach { self.remove(at: $0.element) }
			}
		}
        
//        for change in changes {
//            switch change {
//            case .delete(_):
//                break
//            case .insert(let insert):
//                self.append(insert.item)
//                break
//            case .replace(let replace):
//                self[replace.index].copy(from: replace.newItem)
//                break
//            case .move(let move):
//                self.remove(at: move.fromIndex)
//                self.insert(move.item, at: move.toIndex)
//                break
//			@unknown default:
//				break
//			}
//        }
//
//        let deletes = changes.compactMap { $0.delete }.sorted { $0.index > $1.index }
//        for delete in deletes {
//            self.remove(at: delete.index)
//        }
        
        return changes
    }
    
    mutating func remove(at indexes: [Int]) {
        for index in indexes.sorted(by: >) {
            remove(at: index)
        }
    }
    
    mutating func remove(at indexSet: IndexSet) {
        self.remove(at: indexSet.map { $0 })
    }
}
