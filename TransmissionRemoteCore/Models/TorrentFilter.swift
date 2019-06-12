import Foundation
import DeepDiff

public class TorrentFilter: Mergeable {
	public var name = ""
	public var category: Category = .statuses
	public var status: Status? = .all
	public var filteredTorrents: [Torrent] = []
    
    public enum Category: String, CaseIterable {
        case statuses = "Statuses"
        case downloadDirs = "Download dirs"
    }
    
    public enum Status: String, CaseIterable {
        case all = "All"
        case downloading = "Downloading"
        case completed = "Completed"
        case active = "Active"
        case inactive = "Inactive"
        case stopped = "Stopped"
        case error = "Error"
        case waiting = "Waiting"
    }
    
    public var diffId: Int {
        return self.name.hashValue
    }
    
    public static func compareContent(_ a: TorrentFilter, _ b: TorrentFilter) -> Bool {
        return a.name == b.name
            && a.category == b.category
            && a.status == b.status
            && [Torrent].compareContent(a.filteredTorrents, b.filteredTorrents)
    }
	
	init(name: String, filtered: [Torrent], category: Category) {
		self.name = name
		self.filteredTorrents = filtered
		self.category = category
		self.status = nil
	}
	
	init(filtered: [Torrent], status: Status) {
		self.name = status.rawValue
		self.filteredTorrents = filtered
		self.category = .statuses
		self.status = status
	}
    
    public func copy(from item: TorrentFilter) {
        self.filteredTorrents = item.filteredTorrents
    }
}
