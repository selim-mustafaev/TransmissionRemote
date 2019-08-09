import Foundation
import DeepDiff

public enum Priority: Int, CustomStringConvertible {
    case low = -1
    case normal = 0
    case high = 1
    
    public var description: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        }
    }
}

public class TorrentFile: Decodable, Mergeable, Hashable {
    public var name: String
    public var length: Int64
    public var bytesCompleted: Int64
    public var enabled: Bool = true
	public var priority: Priority = .normal
    public var wanted: Bool = true
    
    public weak var torrent: Torrent?
    public var securityScopedUrl: URL?
    
    public init() {
        self.name = ""
        self.length = 0
        self.bytesCompleted = 0
    }
    
    public init(name: String, length: Int64) {
        self.name = name
        self.length = length
        self.bytesCompleted = 0
    }
    
    // MARK: - Hashable
    
    public static func == (lhs: TorrentFile, rhs: TorrentFile) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.length)
        hasher.combine(self.bytesCompleted)
    }
	
	// MARK: - Mergeable
	
	public var diffId: Int {
		return name.hashValue
	}
    
    public static func compareContent(_ a: TorrentFile, _ b: TorrentFile) -> Bool {
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
	
	public func downloadedPercents() -> Float {
		if self.length == 0 {
			return 0.0
		} else {
            let result = 100.0*Float(self.bytesCompleted)/Float(self.length)
            return result <= 100.0 ? result : 100.0
		}
	}
    
    public func withLocalURL(closure: (URL?) -> Void) {
        guard let torrent = self.torrent else {
            closure(nil)
            return
        }
        
        let serverPath = torrent.downloadDir + "/" + self.name
        
        for association in Settings.shared.pathAssociations {
            if serverPath.starts(with: association.remotePath) {
                let localPath = serverPath.replacingOccurrences(of: association.remotePath, with: association.localPath)
                association.withLocalUrl { url in
                    guard url != nil else {
                        closure(nil)
                        return
                    }
                    closure(URL(fileURLWithPath: localPath))
                }
                return
            }
        }
        
        closure(nil)
    }
    
    public func startAccess() -> URL? {
        guard let torrent = self.torrent else { return nil }
        
        let serverPath = torrent.downloadDir + "/" + self.name
        for association in Settings.shared.pathAssociations {
            if serverPath.starts(with: association.remotePath) {
                let localPath = serverPath.replacingOccurrences(of: association.remotePath, with: association.localPath)
                self.securityScopedUrl = association.securityScopedURL()
                if self.securityScopedUrl?.startAccessingSecurityScopedResource() == true {
                    return URL(fileURLWithPath: localPath)
                } else {
                    return nil
                }
            }
        }
        
        return nil
    }
    
    public func stopAccess() {
        self.securityScopedUrl?.stopAccessingSecurityScopedResource()
    }
    
}
