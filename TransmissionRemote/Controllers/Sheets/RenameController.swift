import Cocoa
import TransmissionRemoteCore

class RenameController: NSViewController, NSTextFieldDelegate {
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var okButton: NSButton!
    
    var torrent: Torrent!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name.stringValue = self.torrent?.name ?? ""
    }
    
    // MARK: - Actions
    
    @MainActor
    func renameTorrent() async {
        do {
            try await Api.rename(path: torrent.name,
                                 to: self.name.stringValue,
                                 in: torrent.id)
            
            await Service.shared.updateTorrents()
            self.dismiss(nil)
        } catch {
            if let wnd = self.view.window {
                NSAlert.showError(error, for: wnd)
            }
        }
    }
    
    @IBAction func ok(_ sender: NSButton) {
        Task { await renameTorrent() }
    }
    
    func controlTextDidChange(_ obj: Notification) {
        if self.name.stringValue.count == 0 || self.name.stringValue == torrent.name {
            self.okButton.isEnabled = false
        } else {
            self.okButton.isEnabled = true
        }
    }
}
