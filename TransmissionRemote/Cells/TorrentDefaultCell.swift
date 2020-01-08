import Cocoa
import TransmissionRemoteCore

class TorrentCell: ConfigurableCell<Torrent> {
    override func configure(with torrent: Torrent, at column: NSUserInterfaceItemIdentifier) {
        switch column {
        case .name:
            self.textField?.stringValue = torrent.name
			self.setAccessibilityLabel(torrent.name)
            break
        case .size:
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            self.textField?.stringValue = formatter.string(fromByteCount: torrent.totalSize)
            break
        case .seeds:
            self.textField?.stringValue = String(torrent.peersSendingToUs)
            break
        case .peers:
            self.textField?.stringValue = String(torrent.peersGettingFromUs)
            break
        case .downSpeed:
            if torrent.rateDownload > 0 {
                let formatter = ByteCountFormatter()
                formatter.countStyle = .file
                self.textField?.stringValue = formatter.string(fromByteCount: Int64(torrent.rateDownload)) + "/s"
            } else {
                self.textField?.stringValue = ""
            }
            break
        case .upSpeed:
            if torrent.rateUpload > 0 {
                let formatter = ByteCountFormatter()
                formatter.countStyle = .file
                self.textField?.stringValue = formatter.string(fromByteCount: Int64(torrent.rateUpload)) + "/s"
            } else {
                self.textField?.stringValue = ""
            }
            break
        case .eta:
            if torrent.eta > 0 {
                let formatter = DateComponentsFormatter()
                self.textField?.stringValue = formatter.string(from: TimeInterval(torrent.eta)) ?? ""
            } else {
                self.textField?.stringValue = ""
            }
            break
        case .ratio:
            self.textField?.stringValue = String(format: "%.1f", torrent.uploadRatio)
            break
        case .queuePosition:
            self.textField?.stringValue = String(torrent.queuePosition)
            break
        case .seedingTime:
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.day, .hour]
            formatter.unitsStyle = .abbreviated
            let interval = TimeInterval(torrent.secondsSeeding)
            self.textField?.stringValue = formatter.string(from: interval) ?? ""
            break
        case .addedDate:
            let date = Date(timeIntervalSince1970: TimeInterval(torrent.addedDate))
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            self.textField?.stringValue = formatter.string(from: date)
            break
        case .activityDate:
            let date = Date(timeIntervalSince1970: TimeInterval(torrent.activityDate))
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            self.textField?.stringValue = formatter.string(from: date)
            break
        case .uploaded:
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            self.textField?.stringValue = formatter.string(fromByteCount: torrent.uploadedEver)
            break
        case .downloaded:
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            self.textField?.stringValue = formatter.string(fromByteCount: torrent.downloadedEver)
            break
        default:
            self.textField?.stringValue = ""
            break
        }
    }
}
