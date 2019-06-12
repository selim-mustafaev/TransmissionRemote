import Foundation
import Cocoa
import TransmissionRemoteCore

class TorrentPriorityCell: ConfigurableCell<Torrent> {
    @IBOutlet weak var priorityBadge: NSImageView!
    
    static let greenBadge = NSImage(named: "NSStatusAvailable")
    static let orangeBadge = NSImage(named: "NSStatusPartiallyAvailable")
    static let redBadge = NSImage(named: "NSStatusUnavailable")
    static let grayBadge = NSImage(named: "NSStatusNone")
    
    override func configure(with torrent: Torrent, at column: NSUserInterfaceItemIdentifier) {
        self.textField?.stringValue = torrent.bandwidthPriority.description
        
        switch torrent.bandwidthPriority {
        case .low:
            self.priorityBadge.image = FilePriorityCell.orangeBadge
            break
        case .normal:
            self.priorityBadge.image = FilePriorityCell.greenBadge
            break
        case .high:
            self.priorityBadge.image = FilePriorityCell.redBadge
            break
        }
    }
}
