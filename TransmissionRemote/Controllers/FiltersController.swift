import Cocoa
import DeepDiff
import TransmissionRemoteCore

class FiltersController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var server: NSTextField!
    @IBOutlet weak var freeSpace: NSTextField!
    @IBOutlet weak var download: NSTextField!
    @IBOutlet weak var upload: NSTextField!
	
    let categories = TorrentFilter.Category.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.outlineView.autosaveExpandedItems = true
		self.outlineView.autosaveName = "FiltersList"
        self.outlineView.reloadData()
        self.outlineView.selectRowIndexes(IndexSet([1]), byExtendingSelection: false)
    }
    
    override func viewWillAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(filtersUpdated(_:)), name: .updateFilters, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(torrentsUpdated(_:)), name: .updateTorrents, object: nil)
    }
    
    override func viewDidDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notification handlers
    
    @objc func filtersUpdated(_ notification: Notification) {
		guard let dirChanges = notification.userInfo?["dirChanges"] as? [Change<TorrentFilter>] else { return }
		guard let statusChanges = notification.userInfo?["statChanges"] as? [Change<TorrentFilter>] else { return }
		
		if dirChanges.count == 0 && statusChanges.count == 0 {
			return
		}
		
		self.outlineView.beginUpdates()
		for change in statusChanges {
			switch change {
            case .insert(let insert):
				self.outlineView.insertItems(at: IndexSet([insert.index]), inParent: TorrentFilter.Category.statuses)
				break
            case .delete(let delete):
				self.outlineView.removeItems(at: IndexSet([delete.index]), inParent: TorrentFilter.Category.statuses)
				break
            case .replace(let replace):
                self.outlineView.reloadItem(replace.oldItem)
				break
            case .move(_):
                break
			@unknown default:
				break
			}
		}
		
		for change in dirChanges {
			switch change {
			case .insert(let insert):
				self.outlineView.insertItems(at: IndexSet([insert.index]), inParent: TorrentFilter.Category.downloadDirs)
				break
			case .delete(_):
				break
			case .replace(let replace):
				self.outlineView.reloadItem(replace.oldItem)
				break
            case .move(_):
                break
			@unknown default:
				break
			}
		}
        
        let deletes = dirChanges.compactMap { $0.delete }.sorted { $0.index > $1.index }
        for delete in deletes {
            self.outlineView.removeItems(at: IndexSet([delete.index]), inParent: TorrentFilter.Category.downloadDirs)
        }
		
		self.outlineView.endUpdates()
    }
    
    @objc func torrentsUpdated(_ notification: Notification) {
        guard let session = Service.shared.session else { return }
        guard let torrents = notification.userInfo?["torrents"] as? [Torrent] else { return }
        
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        
        let totalDownload = torrents.map { $0.rateDownload }.reduce(0, +)
        let totalUpload = torrents.map { $0.rateUpload }.reduce(0, +)
        
        self.server.stringValue = "Transmission " + session.version
        self.freeSpace.stringValue = formatter.string(fromByteCount: session.freeSpace)
        self.download.stringValue = formatter.string(fromByteCount: totalDownload) + "/s"
        self.upload.stringValue = formatter.string(fromByteCount: totalUpload) + "/s"
    }
    
    // MARK: - NSOutlineViewDataSource
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return self.categories.count
        }
        
        if let category = item as? TorrentFilter.Category {
            switch category {
                case .statuses: return TorrentFilter.Status.allCases.count
                case .downloadDirs: return Service.shared.dirFilters.count
            }
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return self.categories[index]
        }
        
        if let category = item as? TorrentFilter.Category {
            switch category {
            case .statuses:
				return Service.shared.statusFilters[index]
            case .downloadDirs:
				return Service.shared.dirFilters[index]
            }
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let category = item as? TorrentFilter.Category {
            switch category {
			case .statuses: return true
			case .downloadDirs: return Service.shared.dirFilters.count > 0
            }
        }
        return false
    }
    
    // MARK: - NSOutlineViewDelegate
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let filter = item as? TorrentFilter {
            let cell = outlineView.makeView(withIdentifier: .dataCell, owner: nil) as? FilterCell
            cell?.configure(with: filter)
			return cell
        }
        else if let category = item as? TorrentFilter.Category {
            let cell = outlineView.makeView(withIdentifier: .headerCell, owner: nil) as? NSTableCellView
            cell?.textField?.stringValue = category.rawValue
			return cell
        }
        
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is TorrentFilter.Category
    }
	
	func outlineView(_ outlineView: NSOutlineView, persistentObjectForItem item: Any?) -> Any? {
		if let category  = item as? TorrentFilter.Category {
			return category.rawValue
		}
		
		return nil
	}
	
	func outlineView(_ outlineView: NSOutlineView, itemForPersistentObject object: Any) -> Any? {
		if let category  = object as? String {
			return TorrentFilter.Category(rawValue: category)
		}
		
		return nil
	}
	
	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		return outlineView.parent(forItem: item) != nil
	}
	
	func outlineViewSelectionDidChange(_ notification: Notification) {
		if let filter = self.outlineView.item(atRow: self.outlineView.selectedRow) as? TorrentFilter {
			Service.shared.setCurrentFilter(filter)
		}
	}
}
