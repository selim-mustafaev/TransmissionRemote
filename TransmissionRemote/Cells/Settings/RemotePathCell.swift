import Cocoa

class RemotePathCell: ConfigurableCell<PathAssociation> {
    
    override func configure(with mapping: PathAssociation, at column: NSUserInterfaceItemIdentifier) {
        self.textField?.stringValue = mapping.remotePath
    }
    
}
