import Foundation
import DifferenceKit

public class TorrentFilter: Mergeable, CustomStringConvertible {
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
    
    public var differenceIdentifier: Int {
        return self.name.hashValue
    }
    
    public var description: String {
        "\(self.name) (\(self.filteredTorrents.count)) - \(Unmanaged.passUnretained(self).toOpaque())"
    }
	
	public func isContentEqual(to source: TorrentFilter) -> Bool {
		return self.name == source.name
            && self.category == source.category
            && self.status == source.status
			&& self.filteredTorrents.isContentEqual(to: source.filteredTorrents)
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
