import Foundation
import BitArray
import DeepDiff

class Torrent: Decodable, Mergeable, CustomStringConvertible {
    var id: Int = 0
    var name: String = ""
    var totalSize: Int64 = 0
    var status: Int = 0
    var downloadDir: String = ""
    var eta: Int = 0
    var leftUntilDone: Int64 = 0
    var peersGettingFromUs: Int = 0
    var peersSendingToUs: Int = 0
    var rateUpload: Int64 = 0
    var rateDownload: Int64 = 0
    var sizeWhenDone: Int64 = 0
    var uploadRatio: Float = 0
    var metadataPercentComplete: Float = 0
    var files: [TorrentFile] = []
	var errorString: String = ""
	var addedDate: Int = 0
	var doneDate: Int = 0
	var pieceCount: Int = 0
	var pieceSize: Int64 = 0
	var pieces: String = ""
	var comment: String = ""
	var downloadedEver: Int64 = 0
	var downloadLimit: Int64 = 0
	var downloadLimited: Bool = false
	var uploadedEver: Int64 = 0
	var uploadLimit: Int64 = 0
	var uploadLimited: Bool = false
	var maxConnectedPeers: Int = 0
	var activityDate: Int = 0
	var trackerStats: [Tracker] = []
	var peers: [Peer] = []
	var priorities: [Int] = []
    var wanted: [Int] = []
    var bandwidthPriority: Priority = .normal
    var queuePosition: Int = 0
    var secondsSeeding: Int64 = 0
    
	enum Status: Int, CustomStringConvertible {
        case stopped = 0
        case checkWait = 1
        case checking = 2
        case downloadWait = 3
        case downloading = 4
        case seedWait = 5
        case seeding = 6
		
		var description: String {
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
    
    enum Source {
        case file(URL)
        case link(String)
    }
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        return self.name
    }
	
	// MARK: - Mergeable
    
    var diffId: Int {
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
    
    func copy(from item: Torrent) {
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
	
	// MARK: - Decodable
	
	enum CodingKeys: String, CodingKey {
		case id, name, totalSize, status, downloadDir, eta, leftUntilDone, peersGettingFromUs, peersSendingToUs, rateUpload, rateDownload, sizeWhenDone, uploadRatio, metadataPercentComplete, files, errorString, addedDate, doneDate, pieceCount, pieceSize, comment, downloadedEver, downloadLimit, downloadLimited, uploadedEver, uploadLimit, uploadLimited, maxConnectedPeers, activityDate, pieces, trackerStats, peers, priorities, wanted, bandwidthPriority, queuePosition, secondsSeeding
	}
	
    required init(from decoder: Decoder) throws {
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
	}
	
	// MARK: - Common
    
    init(name: String, files: [TorrentFile]) {
        self.name = name
        self.files = files
    }
    
    func downloadedPercents() -> Float {
        if self.leftUntilDone == 0 {
            return self.totalSize == 0 ? 0.0 : 100.0
        } else {
            return (1.0 - Float(self.leftUntilDone)/Float(self.totalSize))*100.0
        }
    }
    
    func getStatus() -> Status {
        return Status(rawValue: self.status) ?? .stopped
    }
	
	func isFinished() -> Bool {
		let status = self.getStatus();
		return status == .seeding || (status == .stopped && self.leftUntilDone == 0)
	}
	
	func isActive() -> Bool {
		return self.rateDownload > 0 || self.rateUpload > 0
	}
	
	func isError() -> Bool {
		return self.errorString.count > 0
	}
	
	func getPieces() -> BitArray {
		guard let data = Data(base64Encoded: self.pieces) else { return [] }
		return BitArray(self.pieceCount, contentByBytes: Array(data))
	}
    
    // We cannot figure out real torrent path here, so, return array of possible locations
    func serverPath() -> [URL] {
        var result = [
            URL(fileURLWithPath: self.downloadDir + "/" + self.name),
            URL(fileURLWithPath: self.downloadDir + "/" + self.name + ".part")
        ]
        
        if let session = Service.shared.session, session.incompleteDirEnabled && !self.isFinished() {
            result.append(URL(fileURLWithPath: session.incompleteDir + "/" + self.name + ".part"))
        }
        
        return result
    }
}

// MARK: - Wrappers for parsing response from transmission

struct TorrentsWrapper: Decodable {
    let torrents: [Torrent]
}

struct TorrentAdded: Decodable {
    let id: Int
    let name: String
}

struct TorrentAddedWrapper: Decodable {
    let torrentAdded: TorrentAdded
    
    enum CodingKeys: String, CodingKey {
        case torrentAdded = "torrent-added"
    }
}

struct Empty: Decodable {
    
}
