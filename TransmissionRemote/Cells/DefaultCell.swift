import Foundation
import Cocoa

class TrackerCell: ConfigurableCell<Tracker> {
	public override func configure(with item: Tracker, at column: NSUserInterfaceItemIdentifier) {
		switch column {
		case .trackerName:
			self.textField?.stringValue = item.host
			break
		case .trackerStatus:
			if item.lastAnnounceSucceeded {
				self.textField?.stringValue = "Working"
			} else {
				self.textField?.stringValue = item.lastAnnounceResult
			}
			break
		case .trackerUpdateIn:
			let formatter = DateComponentsFormatter()
			let interval = TimeInterval(item.nextAnnounceTime) - Date().timeIntervalSince1970
			self.textField?.stringValue = formatter.string(from: interval) ?? ""
			break
		case .trackerSeeds:
			self.textField?.stringValue = item.seederCount > 0 ? String(item.seederCount) : ""
			break
		default:
			self.textField?.stringValue = ""
			break
		}
	}
}

class PeerCell: ConfigurableCell<Peer> {
	public override func configure(with item: Peer, at column: NSUserInterfaceItemIdentifier) {
		switch column {
		case .peerHost:
			self.textField?.stringValue = item.address
			break
		case .peerPort:
			self.textField?.stringValue = String(item.port)
			break
		case .peerCountry:
			self.textField?.stringValue = "" // TODO: Fill country
			break
		case .peerClient:
			self.textField?.stringValue = item.clientName
			break
		case .peerFlags:
			self.textField?.stringValue = item.flagStr
			break
		case .peerHave:
			self.textField?.stringValue = String(format: "%.2f%%", item.progress*100)
			break
		case .peerUpSpeed:
			if item.rateToPeer == 0 {
				self.textField?.stringValue = ""
			} else {
				let formatter = ByteCountFormatter()
				formatter.countStyle = .file
				self.textField?.stringValue = formatter.string(fromByteCount: item.rateToPeer) + "/s"
			}
			break
		case .peerDownSpeed:
			if item.rateToClient == 0 {
				self.textField?.stringValue = ""
			} else {
				let formatter = ByteCountFormatter()
				formatter.countStyle = .file
				self.textField?.stringValue = formatter.string(fromByteCount: item.rateToClient) + "/s"
			}
			break
		default:
			self.textField?.stringValue = ""
			break
		}
	}
}

class FileCell: ConfigurableCell<TorrentFile> {
	public override func configure(with item: TorrentFile, at column: NSUserInterfaceItemIdentifier) {
		let formatter = ByteCountFormatter()
		formatter.countStyle = .file
		
		switch column {
		case .fileName:
			self.textField?.stringValue = item.name
			break
		case .fileSize:
			self.textField?.stringValue = formatter.string(fromByteCount: item.length)
			break
		case .fileDone:
			self.textField?.stringValue = formatter.string(fromByteCount: item.bytesCompleted)
			break
		case .filePercents:
			self.textField?.stringValue = ""
			break
		case .filePriority:
			self.textField?.stringValue = ""
			break
		default:
			self.textField?.stringValue = ""
		}
	}
}
