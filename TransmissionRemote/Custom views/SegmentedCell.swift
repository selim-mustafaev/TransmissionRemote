import Cocoa

class SegmentedCell: NSSegmentedCell {
    
    override var action: Selector? {
        get {
            if self.menu(forSegment: self.selectedSegment) != nil {
                return nil
            }
            return super.action
        }
        set {
            super.action = newValue
        }
    }
    
}
