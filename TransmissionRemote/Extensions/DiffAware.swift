import Foundation
import DeepDiff

extension Array: DiffAware where Element: DiffAware {
    
    public var diffId: Int {
        var hasher = Hasher()
        for item in self {
            hasher.combine(item.diffId)
        }
        return hasher.finalize()
    }
    
    public static func compareContent(_ a: Array<Element>, _ b: Array<Element>) -> Bool {
        guard a.count == b.count else { return false }
        
        for index in a.indices {
            if !Element.compareContent(a[index], b[index]) {
                return false
            }
        }
        
        return true
    }
}
