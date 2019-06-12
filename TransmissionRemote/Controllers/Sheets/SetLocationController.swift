import Cocoa
import TransmissionRemoteCore

class SetLocationController: NSViewController {
    
    @IBOutlet weak var path: NSComboBox!
    @IBOutlet weak var move: NSButton!
    
    var ids: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.path.addItems(withObjectValues: Service.shared.dirFilters.map { $0.name })
        self.path.selectItem(at: 0)
    }
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: NSButton) {
        self.dismiss(nil)
    }
    
    @IBAction func ok(_ sender: NSButton) {
        guard let wnd = self.view.window else { return }
        guard self.path.stringValue.count > 0 else {
            NSAlert.showError("Invalid new location", description: "New path must not be empty", for: wnd)
            return
        }
        
        Api.set(location: self.path.stringValue, for: self.ids, move: self.move.state == .on)
            .done { self.dismiss(nil) }
            .catch { error in
                print("Error setting new location: ", error)
                self.dismiss(nil)
            }
        
        self.dismiss(nil)
    }
    
    @IBAction func browse(_ sender: NSButton) {
        guard let wnd = self.view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: wnd) { response in
            if response == .OK {
                if let url = panel.url {
                    for index in Settings.shared.pathAssociations.indices {
                        if url.path.starts(with: Settings.shared.pathAssociations[index].localPath) {
                            let remotePath = url.path.replacingOccurrences(of: Settings.shared.pathAssociations[index].localPath, with: Settings.shared.pathAssociations[index].remotePath)
                            self.path.stringValue = remotePath
                            return
                        }
                    }
                    
                    NSAlert.showError("Path selection error", description: "Cannot find remote path associated with selected local path", for: wnd)
                }
            }
        }
    }
}
