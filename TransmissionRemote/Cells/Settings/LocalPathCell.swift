import Cocoa

class LocalPathCell: ConfigurableCell<PathAssociation> {
    
    var remotePath: String = ""
    
    override func configure(with mapping: PathAssociation, at column: NSUserInterfaceItemIdentifier) {
        self.textField?.stringValue = mapping.localPath
        self.remotePath = mapping.remotePath
    }
    
    @IBAction func browseAction(_ sender: NSButton) {
        guard let wnd = sender.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: wnd) { response in
            if response == .OK {
                if let url = panel.url {
                    for index in Settings.shared.pathAssociations.indices {
                        if Settings.shared.pathAssociations[index].remotePath == self.remotePath {
                            self.textField?.stringValue = url.path
                            Settings.shared.pathAssociations[index].setLocal(url: url)
                        }
                    }
                }
            }
        }
    }
    
}
