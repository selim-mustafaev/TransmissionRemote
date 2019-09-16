import Cocoa
import TransmissionRemoteCore

class PathsSettingController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var addAssociationMenu: NSMenu!
    
    var associationsDS: CollectionArrayDataSource<PathAssociation>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.associationsDS = CollectionArrayDataSource<PathAssociation>(collectionView: self.tableView, array: Settings.shared.pathAssociations)
        self.rebuildMenu()
    }
    
    @IBAction func removeAction(_ sender: NSButton) {
        Settings.shared.pathAssociations.remove(at: self.tableView.selectedRowIndexes)
        self.associationsDS?.setData(Settings.shared.pathAssociations)
    }
    
    @objc func addPathAction(_ sender: NSMenuItem) {
        Settings.shared.pathAssociations.append(PathAssociation(remote: sender.title))
        self.associationsDS?.setData(Settings.shared.pathAssociations)
    }
    
    @objc func addCustomPathAction(_ sender: NSMenuItem) {
        guard let wnd = self.view.window else { return }
        
        let textField = NSTextField(string: "")
        textField.frame = textField.frame.insetBy(dx: -200, dy: 0)
        
        let alert = NSAlert()
        alert.messageText = "Enter remote path"
        alert.informativeText = "You can use 'download-dir' value from settings.json (transmission's config file), or root of samba share (if you have one), or whatever path, somehow mapped to your local folder."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.accessoryView = textField
        alert.beginSheetModal(for: wnd) { response in
            if response == .alertFirstButtonReturn {
                let path = textField.stringValue
                if path.count == 0 {
                    NSAlert.showError("Path must not be empty", suggestion: "", for: wnd)
                } else if Settings.shared.pathAssociations.contains(where: { assoc in assoc.remotePath == path }) {
                    NSAlert.showError("Path already exists", suggestion: "", for: wnd)
                } else {
                    Settings.shared.pathAssociations.append(PathAssociation(remote: path))
                    self.associationsDS?.setData(Settings.shared.pathAssociations)
                }
            }
        }
        
    }
 
    func rebuildMenu() {
        let plus = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        plus.image = NSImage(named: "NSAddTemplate")
        
        self.addAssociationMenu.removeAllItems()
        self.addAssociationMenu.addItem(plus)
        for filter in Service.shared.dirFilters {
            self.addAssociationMenu.addItem(withTitle: filter.name, action: #selector(addPathAction(_:)), keyEquivalent: "")
        }
        self.addAssociationMenu.addItem(.separator())
        self.addAssociationMenu.addItem(withTitle: "Custom", action: #selector(addCustomPathAction(_:)), keyEquivalent: "")
    }
}
