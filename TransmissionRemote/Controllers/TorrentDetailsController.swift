import Cocoa
import TransmissionRemoteCore

enum TorrentTab: Int {
	case general = 0
	case trackers = 1
	case peers = 2
	case files = 3
}

class TorrentDetailsController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var generalTabButton: NSButton!
    @IBOutlet weak var trackersTabButton: NSButton!
    @IBOutlet weak var peersTabButton: NSButton!
    @IBOutlet weak var filesTabButton: NSButton!
    @IBOutlet weak var tabView: NSTabView!
	
	@IBOutlet weak var nameLabel: NSTextField!
	@IBOutlet weak var pathLabel: NSTextField!
	@IBOutlet weak var totalSizeLabel: NSTextField!
	@IBOutlet weak var addedOnLabel: NSTextField!
	@IBOutlet weak var completedOnLabel: NSTextField!
	@IBOutlet weak var piecesLabel: NSTextField!
	@IBOutlet weak var commentLabel: NSTextField!
	
	@IBOutlet weak var downloadedLabel: NSTextField!
	@IBOutlet weak var downloadSpeedLabel: NSTextField!
	@IBOutlet weak var downLimitLabel: NSTextField!
	@IBOutlet weak var uploadedLabel: NSTextField!
	@IBOutlet weak var uploadSpeedLabel: NSTextField!
	@IBOutlet weak var upLimitLabel: NSTextField!
	
	@IBOutlet weak var statusLabel: NSTextField!
	@IBOutlet weak var errorLabel: NSTextField!
	@IBOutlet weak var remainingLabel: NSTextField!
	@IBOutlet weak var maxPeersLabel: NSTextField!
	@IBOutlet weak var trackerLabel: NSTextField!
	@IBOutlet weak var trackerUpdateOnLabel: NSTextField!
	@IBOutlet weak var lastActiveLabel: NSTextField!
	
	@IBOutlet weak var piecesView: PiecesView!
	
	@IBOutlet weak var trackersTable: NSTableView!
	@IBOutlet weak var peersTable: NSTableView!
	@IBOutlet weak var filesTable: NSTableView!
    
    var activeTabButton: NSButton!
	var torrent: Torrent? = nil
	
	typealias TrackersDataSourse = CollectionArrayDataSource<Tracker>
	typealias PeersDataSource = CollectionArrayDataSource<Peer>
	typealias FilesDataSource = CollectionArrayDataSource<TorrentFile>
	
	var trackersDS: TrackersDataSourse?
	var peersDS: PeersDataSource?
	var filesDS: FilesDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.trackersDS = TrackersDataSourse(collectionView: self.trackersTable, array: [Tracker]())
		self.peersDS = PeersDataSource(collectionView: self.peersTable, array: [Peer]())
		self.filesDS = FilesDataSource(collectionView: self.filesTable, array: [TorrentFile]())
        
        self.trackersDS?.setSortPredicates([
            .trackerName: { $0.host.caseInsensitiveCompare($1.host) == .orderedAscending },
            .trackerUpdateIn: { $0.nextAnnounceTime < $1.nextAnnounceTime },
            .trackerSeeds: { $0.seederCount < $1.seederCount },
            .trackerStatus: { t1, t2 in
                if t1.lastAnnounceSucceeded && t2.lastAnnounceSucceeded { return false }
                if !t1.lastAnnounceSucceeded && !t2.lastAnnounceSucceeded { return false }
                if t1.lastAnnounceSucceeded { return false }
                if t2.lastAnnounceSucceeded { return true }
                return false
            }
        ])
        
        self.activeTabButton = self.generalTabButton
		NotificationCenter.default.addObserver(self, selector: #selector(updateTorrent(_:)), name: .updateSelectedTorrent, object: nil)
    }
	
	// MARK: - Actions
	
	@IBAction func hideDetailsAction(_ sender: NSButton) {
		if let wndController = self.view.window?.windowController as? MainWindowController {
			wndController.hideDetailsPanel()
		}
	}
    
    @IBAction func switchTabAction(_ sender: NSButton) {
        if sender != self.activeTabButton {
            self.activeTabButton.state = .off
            sender.state = .on
            self.activeTabButton = sender
            self.tabView.selectTabViewItem(at: sender.tag)
			
			if let tab = TorrentTab(rawValue: self.activeTabButton.tag), let torrent = self.torrent {
				self.update(tab, with: torrent)
			}
        }
    }
	
	@objc func updateTorrent(_ notification: Notification) {
		guard let torrent = notification.userInfo?["torrent"] as? Torrent else { return }
		guard let tab = TorrentTab(rawValue: self.activeTabButton.tag) else { return }
		
		self.torrent = torrent
		self.update(tab, with: torrent)
	}
	
	func update(_ tab: TorrentTab, with torrent: Torrent) {
		switch tab {
		case .general:
			self.updateGeneralTab(with: torrent)
			break
		case .trackers:
			self.updateTrackersTab()
			break
		case .peers:
			self.updatePeersTab()
			break
		case .files:
			self.updateFilesTab()
			break
		}
	}
	
	// MARK: - Update tabs nethods
	
	func updateGeneralTab(with torrent: Torrent) {
		let bytesFormatter = ByteCountFormatter()
		bytesFormatter.countStyle = .file
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		dateFormatter.timeStyle = .medium
		
		self.nameLabel.stringValue = torrent.name
		self.pathLabel.stringValue = torrent.downloadDir + "/" + torrent.name
		self.totalSizeLabel.stringValue = bytesFormatter.string(fromByteCount: Int64(torrent.totalSize))
		
		if torrent.addedDate > 0 {
			let date = Date(timeIntervalSince1970: TimeInterval(torrent.addedDate))
			self.addedOnLabel.stringValue = dateFormatter.string(from: date)
		}
		
		if torrent.doneDate > 0 {
			let date = Date(timeIntervalSince1970: TimeInterval(torrent.doneDate))
			self.completedOnLabel.stringValue = dateFormatter.string(from: date)
		} else {
			self.completedOnLabel.stringValue = ""
		}
	
		self.piecesLabel.stringValue = "\(torrent.pieceCount) × \(bytesFormatter.string(fromByteCount: torrent.pieceSize))"
		self.commentLabel.stringValue = torrent.comment
		
		self.downloadedLabel.stringValue = bytesFormatter.string(fromByteCount: torrent.downloadedEver)
		self.downloadSpeedLabel.stringValue = bytesFormatter.string(fromByteCount: torrent.rateDownload) + "/s"
		if torrent.downloadLimited {
			self.downLimitLabel.stringValue = bytesFormatter.string(fromByteCount: torrent.downloadLimit*1024) + "/s"
		} else {
			self.downLimitLabel.stringValue = "－"
		}
		
		self.uploadedLabel.stringValue = bytesFormatter.string(fromByteCount: torrent.uploadedEver)
		self.uploadSpeedLabel.stringValue = bytesFormatter.string(fromByteCount: torrent.rateUpload) + "/s"
		if torrent.uploadLimited {
			self.upLimitLabel.stringValue = bytesFormatter.string(fromByteCount: torrent.uploadLimit*1024) + "/s"
		} else {
			self.upLimitLabel.stringValue = "－"
		}
		
		self.statusLabel.stringValue = torrent.getStatus().description
		self.errorLabel.stringValue = torrent.errorString
		self.remainingLabel.stringValue = bytesFormatter.string(fromByteCount: torrent.leftUntilDone)
		self.maxPeersLabel.stringValue = String(torrent.maxConnectedPeers)
		
		let lastActiveDate = Date(timeIntervalSince1970: TimeInterval(torrent.activityDate))
		self.lastActiveLabel.stringValue = dateFormatter.string(from: lastActiveDate)
		
		if let tracker = torrent.trackerStats.first {
			self.trackerLabel.stringValue = tracker.host
			let date = Date(timeIntervalSince1970: TimeInterval(tracker.nextAnnounceTime))
			self.trackerUpdateOnLabel.stringValue = dateFormatter.string(from: date)
		}
		
		self.piecesView.update(with: torrent.getPieces())
	}
	
	func updateTrackersTab() {
		guard let trackers = self.torrent?.trackerStats else { return }
		self.trackersDS?.setData(trackers)
	}
	
	func updatePeersTab() {
		guard let peers = self.torrent?.peers else { return }
		self.peersDS?.setData(peers)
	}
	
	func updateFilesTab() {
		guard let files = self.torrent?.files else { return }
		self.filesDS?.setData(files)
	}
	
	// MARK: - NSTableViewDataSource
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.torrent?.trackerStats.count ?? 0
	}
}
