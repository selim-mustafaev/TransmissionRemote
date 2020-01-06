import Foundation
import DeepDiff

public protocol Mergeable: DiffAware {
    mutating func copy(from item: Self)
}

public extension Array where Element: Mergeable {
    mutating func merge(with array: Array<Element>) -> [Change<Element>] {
        let wf = WagnerFischer<Element>(reduceMove: true)
        let changes = wf.diff(old: self, new: array)
        
        for change in changes {
            switch change {
            case .delete(_):
                break
            case .insert(let insert):
                self.append(insert.item)
                break
            case .replace(let replace):
                self[replace.index].copy(from: replace.newItem)
                break
            case .move(let move):
                self.remove(at: move.fromIndex)
                self.insert(move.item, at: move.toIndex)
                break
			@unknown default:
				break
			}
        }

        let deletes = changes.compactMap { $0.delete }.sorted { $0.index > $1.index }
        for delete in deletes {
            self.remove(at: delete.index)
        }
        
//        self.removeAll()
//        self.append(contentsOf: array)
        
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
