import Cocoa

class CustomCheckBoxCell: NSButtonCell {
    override var nextState: Int {
        get {
            return self.state == .on ? NSControl.StateValue.off.rawValue : NSControl.StateValue.on.rawValue
        }
    }
}
