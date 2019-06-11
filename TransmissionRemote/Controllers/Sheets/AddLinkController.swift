import Cocoa

class AddLinkController: NSViewController {

    @IBOutlet weak var linkField: NSTextField!
    
    var onOk: ((String) -> Void)?
    var onCancel: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Load link from clipboard if possible
    }
    
    // MARK: - Actions
    
    @IBAction func okAction(_ sender: NSButton) {
        let url = self.linkField.stringValue
        if self.isValid(url: url) {
            self.onOk?(url)
        }
        self.dismiss(nil)
    }
    
    @IBAction func cancelAction(_ sender: NSButton) {
        self.onCancel?()
        self.dismiss(nil)
    }
    
    // MARK: - Utils
    
    func isValid(url: String) -> Bool {
        if url.hasSuffix(".torrent") || url.starts(with: "magnet:") {
            return true
        } else {
            return false
        }
    }
}
