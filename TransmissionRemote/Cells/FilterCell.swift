import Cocoa

class FilterCell: NSTableCellView {
	
	@IBOutlet weak var badge: NSButton!

	func configure(with filter: TorrentFilter) {
		if let status = filter.status {
            self.textField?.stringValue = filter.name
			let imgName = NSImage.Name(self.imageName(for: status))
			self.imageView?.image = NSImage(named: imgName)
		} else {
			self.imageView?.image = NSImage(named: "NSTouchBarFolderTemplate")
            let folder = String(filter.name.split(separator: "/").last ?? "")
            self.textField?.stringValue = folder.count > 0 ? folder : filter.name
		}
		
        self.badge.isHidden = filter.filteredTorrents.count == 0
		self.badge.title = String(filter.filteredTorrents.count)
	}
	
	func imageName(for status: StatusFilter) -> String {
		switch status {
		case .all: return "all"
		case .downloading: return "downloading"
		case .completed: return "completed"
		case .active: return "active"
		case .inactive: return "inactive"
		case .stopped: return "stopped"
		case .error: return "error"
		case .waiting: return "waiting"
		}
	}
    
}
