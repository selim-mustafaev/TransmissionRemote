import Foundation
import Cocoa

class FileNameCell: ConfigurableCell<TorrentFile> {
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var wanted: NSButton!
    
    override func configure(with file: TorrentFile, at column: NSUserInterfaceItemIdentifier) {
        self.name.stringValue = file.name
        self.wanted.state = file.wanted ? .on : .off
        
        // For now just showing wanted status
        self.wanted.isEnabled = false
    }
}
