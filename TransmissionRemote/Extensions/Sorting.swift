import Foundation

public typealias SortFunc<T> = (T,T) -> Bool

public class SortPredicate<T> {
    private(set) var sortFunc: SortFunc<T>
    public var ascending: Bool
    
    init(sortFunc: @escaping SortFunc<T>) {
        self.sortFunc = sortFunc
        self.ascending  = true
    }
}

extension MutableCollection where Self : RandomAccessCollection {
    /// Sort `self` in-place using criteria stored in a NSSortDescriptors array
    public mutating func sort(using predicates: [SortPredicate<Self.Iterator.Element>]) {
        sort { by:
            for predicate in predicates {
                if predicate.sortFunc($0, $1) { return predicate.ascending }
                if predicate.sortFunc($1, $0) { return !predicate.ascending }
            }
            return false
        }
        
    }
}

extension Sequence where Iterator.Element : AnyObject {
    /// Return an `Array` containing the sorted elements of `source`
    /// using criteria stored in a NSSortDescriptors array.
    
    public func sorted(using predicates: [SortPredicate<Self.Iterator.Element>]) -> [Self.Iterator.Element] {
        return sorted {
            for predicate in predicates {
                if predicate.sortFunc($0, $1) { return predicate.ascending }
                if predicate.sortFunc($1, $0) { return !predicate.ascending }
            }
            return false
        }
    }
}
