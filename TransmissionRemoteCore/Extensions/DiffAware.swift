import Foundation
import DifferenceKit

extension Array: Differentiable where Element: Differentiable {
    
    public var differenceIdentifier: Int {
        var hasher = Hasher()
        for item in self {
            hasher.combine(item.differenceIdentifier)
        }
        return hasher.finalize()
    }
	
	public func isContentEqual(to source: Array<Element>) -> Bool {
		guard self.count == source.count else { return false }
        
        for index in self.indices {
			if !self[index].isContentEqual(to: source[index]) {
                return false
            }
        }
        
        return true
	}
}
