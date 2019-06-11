import Cocoa

class RenameController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var okButton: NSButton!
    
    var torrent: Torrent!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.stringValue = self.torrent?.name ?? ""
    }
    
    // MARK: - Actions
    
    @IBAction func ok(_ sender: NSButton) {
        guard let wnd = self.view.window else { return }
        
        Api.rename(path: torrent.name, to: self.name.stringValue, in: torrent.id).done {
            Service.shared.updateTorrents()
            self.dismiss(nil)
        }.catch { error in
            NSAlert.showError(error, for: wnd)
        }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if self.name.stringValue.count == 0 || self.name.stringValue == torrent.name {
            self.okButton.isEnabled = false
        } else {
            self.okButton.isEnabled = true
        }
    }
}
