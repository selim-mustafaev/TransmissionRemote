import Cocoa
import TransmissionRemoteCore

class RemotePathCell: ConfigurableCell<PathAssociation> {
    
    override func configure(with mapping: PathAssociation, at column: NSUserInterfaceItemIdentifier) {
        self.textField?.stringValue = mapping.remotePath
    }
    
}
