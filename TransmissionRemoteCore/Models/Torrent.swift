import Foundation
import DeepDiff

public class Torrent: Codable, Mergeable, CustomStringConvertible {
    public var id: Int = 0
    public var name: String = ""
    public var totalSize: Int64 = 0
    public var status: Int = 0
    public var downloadDir: String = ""
    public var eta: Int = 0
    public var leftUntilDone: Int64 = 0
    public var peersGettingFromUs: Int = 0
    public var peersSendingToUs: Int = 0
    public var rateUpload: Int64 = 0
    public var rateDownload: Int64 = 0
    public var sizeWhenDone: Int64 = 0
    public var uploadRatio: Float = 0
    public var metadataPercentComplete: Float = 0
    public var files: [TorrentFile] = []
	public var errorString: String = ""
	public var addedDate: Int = 0
	public var doneDate: Int = 0
	public var pieceCount: Int = 0
	public var pieceSize: Int64 = 0
	public var pieces: String = ""
	public var comment: String = ""
	public var downloadedEver: Int64 = 0
	public var downloadLimit: Int64 = 0
	public var downloadLimited: Bool = false
	public var uploadedEver: Int64 = 0
	public var uploadLimit: Int64 = 0
	public var uploadLimited: Bool = false
	public var maxConnectedPeers: Int = 0
	public var activityDate: Int = 0
	public var trackerStats: [Tracker] = []
	public var peers: [Peer] = []
	public var priorities: [Int] = []
    public var wanted: [Int] = []
    public var bandwidthPriority: Priority = .normal
    public var queuePosition: Int = 0
    public var secondsSeeding: Int64 = 0
    
	public enum Status: Int, CustomStringConvertible {
        case stopped = 0
        case checkWait = 1
        case checking = 2
        case downloadWait = 3
        case downloading = 4
        case seedWait = 5
        case seeding = 6
		
        public var description: String {
			switch self {
			case .stopped: return "Stopped"
			case .checkWait: return "Waiting check"
			case .checking: return "Checking"
			case .downloadWait: return "Waiting donload"
			case .downloading: return "Dowloading"
			case .seedWait: return "Waiting seeding"
			case .seeding: return "Seeding"
			}
		}
    }
    
    public enum Source {
        case file(URL)
        case link(String)
    }
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        return self.name
    }
	
	// MARK: - Mergeable
    
    public var diffId: Int {
        return self.id
    }
    
    public static func compareContent(_ a: Torrent, _ b: Torrent) -> Bool {
        return a.id == b.id
            && a.name == b.name
            && a.totalSize == b.totalSize
            && a.status == b.status
            && a.eta == b.eta
            && a.leftUntilDone == b.leftUntilDone
            && a.peersGettingFromUs == b.peersGettingFromUs
            && a.peersSendingToUs == b.peersSendingToUs
            && a.rateUpload == b.rateUpload
            && a.rateDownload == b.rateDownload
            && a.sizeWhenDone == b.sizeWhenDone
            && a.uploadRatio == b.uploadRatio
            && a.addedDate == b.addedDate
            && a.doneDate == b.doneDate
            && a.downloadedEver == b.downloadedEver
            && a.uploadedEver == b.uploadedEver
            && a.activityDate == b.activityDate
            && a.bandwidthPriority == b.bandwidthPriority
            && a.queuePosition == b.queuePosition
            && a.secondsSeeding == b.secondsSeeding
    }
    
    public func copy(from item: Torrent) {
        self.id = item.id
        self.name = item.name
        self.totalSize = item.totalSize
        self.status = item.status
        self.downloadDir = item.downloadDir
        self.eta = item.eta
        self.leftUntilDone = item.leftUntilDone
        self.peersGettingFromUs = item.peersGettingFromUs
        self.peersSendingToUs = item.peersSendingToUs
        self.rateUpload = item.rateUpload
        self.rateDownload = item.rateDownload
        self.sizeWhenDone = item.sizeWhenDone
        self.uploadRatio = item.uploadRatio
        self.metadataPercentComplete = item.metadataPercentComplete
        self.files = item.files
        self.errorString = item.errorString
		self.addedDate = item.addedDate
		self.doneDate = item.doneDate
		self.pieceCount = item.pieceCount
		self.pieceSize = item.pieceSize
		self.comment = item.comment
		self.downloadedEver = item.downloadedEver
		self.downloadLimit = item.downloadLimit
		self.downloadLimited = item.downloadLimited
		self.uploadedEver = item.uploadedEver
		self.uploadLimit = item.uploadLimit
		self.uploadLimited = item.uploadLimited
		self.maxConnectedPeers = item.maxConnectedPeers
		self.activityDate = item.activityDate
		self.pieces = item.pieces
		self.trackerStats = item.trackerStats
		self.peers = item.peers
		self.priorities = item.priorities
        self.wanted = item.wanted
        self.bandwidthPriority = item.bandwidthPriority
        self.queuePosition = item.queuePosition
        self.secondsSeeding = item.secondsSeeding
    }
	
	// MARK: - Codable
	
	enum CodingKeys: String, CodingKey {
		case id, name, totalSize, status, downloadDir, eta, leftUntilDone, peersGettingFromUs, peersSendingToUs, rateUpload, rateDownload, sizeWhenDone, uploadRatio, metadataPercentComplete, files, errorString, addedDate, doneDate, pieceCount, pieceSize, comment, downloadedEver, downloadLimit, downloadLimited, uploadedEver, uploadLimit, uploadLimited, maxConnectedPeers, activityDate, pieces, trackerStats, peers, priorities, wanted, bandwidthPriority, queuePosition, secondsSeeding
	}
	
    required public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(Int.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		self.totalSize = try container.decode(Int64.self, forKey: .totalSize)
		self.status = try container.decode(Int.self, forKey: .status)
		self.downloadDir = try container.decode(String.self, forKey: .downloadDir)
        self.eta = try container.decode(Int.self, forKey: .eta)
        self.leftUntilDone = try container.decode(Int64.self, forKey: .leftUntilDone)
        self.peersGettingFromUs = try container.decode(Int.self, forKey: .peersGettingFromUs)
        self.peersSendingToUs = try container.decode(Int.self, forKey: .peersSendingToUs)
        self.rateUpload = try container.decode(Int64.self, forKey: .rateUpload)
        self.rateDownload = try container.decode(Int64.self, forKey: .rateDownload)
        self.sizeWhenDone = try container.decode(Int64.self, forKey: .sizeWhenDone)
        self.uploadRatio = try container.decode(Float.self, forKey: .uploadRatio)
        self.metadataPercentComplete = try container.decode(Float.self, forKey: .metadataPercentComplete)
        self.files = (try? container.decode([TorrentFile].self, forKey: .files)) ?? []
        self.errorString = try container.decode(String.self, forKey: .errorString)
        self.addedDate = try container.decode(Int.self, forKey: .addedDate)
        self.doneDate = try container.decode(Int.self, forKey: .doneDate)
        self.pieceCount = try container.decode(Int.self, forKey: .pieceCount)
        self.pieceSize = try container.decode(Int64.self, forKey: .pieceSize)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.downloadedEver = try container.decode(Int64.self, forKey: .downloadedEver)
        self.downloadLimit = try container.decode(Int64.self, forKey: .downloadLimit)
        self.downloadLimited = try container.decode(Bool.self, forKey: .downloadLimited)
        self.uploadedEver = try container.decode(Int64.self, forKey: .uploadedEver)
        self.uploadLimit = try container.decode(Int64.self, forKey: .uploadLimit)
        self.uploadLimited = try container.decode(Bool.self, forKey: .uploadLimited)
        self.maxConnectedPeers = try container.decode(Int.self, forKey: .maxConnectedPeers)
        self.activityDate = try container.decode(Int.self, forKey: .activityDate)
        self.pieces = try container.decode(String.self, forKey: .pieces)
        self.trackerStats = try container.decode([Tracker].self, forKey: .trackerStats)
        self.peers = try container.decode([Peer].self, forKey: .peers)
        self.priorities = try container.decode([Int].self, forKey: .priorities)
        self.wanted = try container.decode([Int].self, forKey: .wanted)
        self.bandwidthPriority = Priority(rawValue: try container.decode(Int.self, forKey: .bandwidthPriority)) ?? .normal
        self.queuePosition = try container.decode(Int.self, forKey: .queuePosition)
        self.secondsSeeding = try container.decode(Int64.self, forKey: .secondsSeeding)
        
        for index in self.priorities.indices {
            self.files[index].priority = Priority(rawValue: self.priorities[index]) ?? .normal
        }
        
        for index in self.wanted.indices {
            self.files[index].wanted = self.wanted[index] == 0 ? false : true
        }
        
        for index in self.files.indices {
            self.files[index].torrent = self
        }
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.name, forKey: .name)
		try container.encode(self.totalSize, forKey: .totalSize)
		try container.encode(self.status, forKey: .status)
		try container.encode(self.downloadDir, forKey: .downloadDir)
		try container.encode(self.eta, forKey: .eta)
		try container.encode(self.leftUntilDone, forKey: .leftUntilDone)
		try container.encode(self.peersGettingFromUs, forKey: .peersGettingFromUs)
		try container.encode(self.peersSendingToUs, forKey: .peersSendingToUs)
		try container.encode(self.rateUpload, forKey: .rateUpload)
		try container.encode(self.rateDownload, forKey: .rateDownload)
		try container.encode(self.sizeWhenDone, forKey: .sizeWhenDone)
		try container.encode(self.uploadRatio, forKey: .uploadRatio)
		try container.encode(self.metadataPercentComplete, forKey: .metadataPercentComplete)
		try container.encode(self.files, forKey: .files)
		try container.encode(self.errorString, forKey: .errorString)
		try container.encode(self.addedDate, forKey: .addedDate)
		try container.encode(self.doneDate, forKey: .doneDate)
		try container.encode(self.pieceCount, forKey: .pieceCount)
		try container.encode(self.pieceSize, forKey: .pieceSize)
		try container.encode(self.comment, forKey: .comment)
		try container.encode(self.downloadedEver, forKey: .downloadedEver)
		try container.encode(self.downloadLimit, forKey: .downloadLimit)
		try container.encode(self.downloadLimited, forKey: .downloadLimited)
		try container.encode(self.uploadedEver, forKey: .uploadedEver)
		try container.encode(self.uploadLimit, forKey: .uploadLimit)
		try container.encode(self.uploadLimited, forKey: .uploadLimited)
		try container.encode(self.maxConnectedPeers, forKey: .maxConnectedPeers)
		try container.encode(self.activityDate, forKey: .activityDate)
		try container.encode(self.pieces, forKey: .pieces)
		try container.encode(self.trackerStats, forKey: .trackerStats)
		try container.encode(self.peers, forKey: .peers)
		try container.encode(self.priorities, forKey: .priorities)
		try container.encode(self.wanted, forKey: .wanted)
		try container.encode(self.bandwidthPriority, forKey: .bandwidthPriority)
		try container.encode(self.queuePosition, forKey: .queuePosition)
		try container.encode(self.secondsSeeding, forKey: .secondsSeeding)
	}
	
	// MARK: - Common
    
    public init(name: String, files: [TorrentFile]) {
        self.name = name
        self.files = files
    }
    
    public func downloadedPercents() -> Float {
        if self.leftUntilDone == 0 {
            return self.totalSize == 0 ? 0.0 : 100.0
        } else {
            return (1.0 - Float(self.leftUntilDone)/Float(self.totalSize))*100.0
        }
    }
    
    public func getStatus() -> Status {
        return Status(rawValue: self.status) ?? .stopped
    }
	
	public func isFinished() -> Bool {
		let status = self.getStatus();
		return status == .seeding || (status == .stopped && self.leftUntilDone == 0)
	}
	
	public func isActive() -> Bool {
		return self.rateDownload > 0 || self.rateUpload > 0
	}
	
	public func isError() -> Bool {
		return self.errorString.count > 0
	}
	
//	public func getPieces() -> BitArray {
//		guard let data = Data(base64Encoded: self.pieces) else { return [] }
//		return BitArray(self.pieceCount, contentByBytes: Array(data))
//	}
    
    // We cannot figure out real torrent path here, so, return array of possible locations
    public func serverPath() -> [URL] {
        var result = [
            URL(fileURLWithPath: self.downloadDir + "/" + self.name),
            URL(fileURLWithPath: self.downloadDir + "/" + self.name + ".part")
        ]
        
        if let session = Service.shared.session, session.incompleteDirEnabled && !self.isFinished() {
            result.append(URL(fileURLWithPath: session.incompleteDir + "/" + self.name + ".part"))
        }
        
        return result
    }
	
    public func withLocalPath(closure: (String?, TorrentError?) -> Void) {
        var error: TorrentError? = nil
        let urls = self.serverPath()
        for url in urls {
            let path = url.path
            for association in Settings.shared.pathAssociations {
                if path.starts(with: association.remotePath) {
                    let localPath = path.replacingOccurrences(of: association.remotePath, with: association.localPath)
                    
                    if !FileManager.default.fileExists(atPath: localPath) && error == nil {
                        error = .localPathNotFound(torrentName: self.name, localPath: localPath)
                        continue
                    }
                    
                    association.withLocalUrl { url in
                        if url != nil {
                            closure(localPath, nil)
                        } else {
                            closure(nil, .localPathNotFound(torrentName: self.name, localPath: localPath))
                        }
                    }
                    return
                }
            }
        }
        
        if error != nil {
            closure(nil, error)
        } else {
            closure(nil, .associationNotFound(torrentName: self.name))
        }
    }
}

// MARK: - Wrappers for parsing response from transmission

struct TorrentsWrapper: Codable {
    let torrents: [Torrent]
}

struct TorrentAdded: Codable {
    let id: Int
    let name: String
}

struct TorrentAddedWrapper: Codable {
    let torrentAdded: TorrentAdded
    
    enum CodingKeys: String, CodingKey {
        case torrentAdded = "torrent-added"
    }
}

struct Empty: Codable {
    
}
