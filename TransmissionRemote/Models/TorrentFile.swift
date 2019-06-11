import Foundation
import DeepDiff

enum Priority: Int, CustomStringConvertible {
    case low = -1
    case normal = 0
    case high = 1
    
    var description: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        }
    }
}

class TorrentFile: Decodable, Mergeable {
    var name: String
    var length: Int64
    var bytesCompleted: Int64
    var enabled: Bool = true
	var priority: Priority = .normal
    var wanted: Bool = true
    
    init() {
        self.name = ""
        self.length = 0
        self.bytesCompleted = 0
    }
    
    init(name: String, length: Int64) {
        self.name = name
        self.length = length
        self.bytesCompleted = 0
    }
	
	// MARK: - Mergeable
	
	public var diffId: Int {
		return name.hashValue
	}
    
    static func compareContent(_ a: TorrentFile, _ b: TorrentFile) -> Bool {
        return a.name == b.name
            && a.length == b.length
            && a.bytesCompleted == b.bytesCompleted
            && a.enabled == b.enabled
    }
	
	public func copy(from item: TorrentFile) {
		self.name = item.name
		self.length = item.length
		self.bytesCompleted = item.bytesCompleted
		self.enabled = item.enabled
	}
	
	// MARK: - Codable
	
	enum CodingKeys: String, CodingKey {
		case name
		case length
		case bytesCompleted
	}
	
	// MARK: - Common
	
	func downloadedPercents() -> Float {
		if self.length == 0 {
			return 0.0
		} else {
			return 100.0*Float(self.bytesCompleted)/Float(self.length)
		}
	}
}
