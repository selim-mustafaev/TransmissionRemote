import Foundation
import DeepDiff

enum Category: String, CaseIterable {
	case statuses = "Statuses"
	case downloadDirs = "Download dirs"
}

enum StatusFilter: String, CaseIterable {
	case all = "All"
	case downloading = "Downloading"
	case completed = "Completed"
	case active = "Active"
	case inactive = "Inactive"
	case stopped = "Stopped"
	case error = "Error"
	case waiting = "Waiting"
}

class TorrentFilter: Mergeable {
	var name = ""
	var category: Category = .statuses
	var status: StatusFilter? = .all
	var filteredTorrents: [Torrent] = []
    
    var diffId: Int {
        return self.name.hashValue
    }
    
    static func compareContent(_ a: TorrentFilter, _ b: TorrentFilter) -> Bool {
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
	
	init(filtered: [Torrent], status: StatusFilter) {
		self.name = status.rawValue
		self.filteredTorrents = filtered
		self.category = .statuses
		self.status = status
	}
    
    func copy(from item: TorrentFilter) {
        self.filteredTorrents = item.filteredTorrents
    }
}
