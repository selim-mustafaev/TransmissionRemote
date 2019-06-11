import Cocoa

class ProgressCell: ConfigurableCell<Torrent> {

    @IBOutlet weak var progressView: NSProgressIndicator!
    @IBOutlet weak var progressTextField: NSTextField!
    
    override func configure(with torrent: Torrent, at column: NSUserInterfaceItemIdentifier) {
        let percents = torrent.downloadedPercents()
        if percents == 100 {
            self.progressTextField.stringValue = "Done"
            self.progressView.isHidden = true
        } else {
            self.progressTextField.stringValue = String(format: "%.2f%%", percents)
            self.progressView.doubleValue = Double(percents)
            self.progressView.isHidden = false
        }
    }
}
