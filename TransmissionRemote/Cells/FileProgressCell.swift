import Foundation
import Cocoa
import TransmissionRemoteCore

class FileProgressCell: ConfigurableCell<TorrentFile> {
	
	@IBOutlet weak var progressView: NSProgressIndicator!
	@IBOutlet weak var progressTextField: NSTextField!
	
	override func configure(with file: TorrentFile, at column: NSUserInterfaceItemIdentifier) {
		let percents = file.downloadedPercents()
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
