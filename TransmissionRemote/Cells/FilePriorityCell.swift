import Foundation
import Cocoa

class FilePriorityCell: ConfigurableCell<TorrentFile> {
    @IBOutlet weak var priorityText: NSTextField!
    @IBOutlet weak var priorityBadge: NSImageView!
    
    static let greenBadge = NSImage(named: "NSStatusAvailable")
    static let orangeBadge = NSImage(named: "NSStatusPartiallyAvailable")
    static let redBadge = NSImage(named: "NSStatusUnavailable")
    static let grayBadge = NSImage(named: "NSStatusNone")
    
    override func configure(with file: TorrentFile, at column: NSUserInterfaceItemIdentifier) {
        if file.wanted {
            self.priorityText.stringValue = file.priority.description
            
            switch file.priority {
            case .low:
                self.priorityBadge.image = FilePriorityCell.redBadge
                break
            case .normal:
                self.priorityBadge.image = FilePriorityCell.greenBadge
                break
            case .high:
                self.priorityBadge.image = FilePriorityCell.orangeBadge
                break
            }
        } else {
            self.priorityText.stringValue = "Skipped"
            self.priorityBadge.image = FilePriorityCell.grayBadge
        }
    }
}
