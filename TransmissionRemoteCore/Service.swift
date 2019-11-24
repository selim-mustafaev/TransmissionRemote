import Foundation
import Cocoa
import PromiseKit
import CoreSpotlight
import AVFoundation
import os.log

public class Service {
    public static let shared = Service()
    
    private(set) public var torrents: [Torrent] = []
	private(set) var selectedTorrents: [Torrent] = []
    private(set) public var session: Server? = nil
	private(set) public var statusFilters: [TorrentFilter] = TorrentFilter.Status.allCases.map { TorrentFilter(filtered: [], status: $0) }
	private(set) public var dirFilters: [TorrentFilter] = []
	private(set) var trackerFilters:[TorrentFilter] = []
	private(set) var currentFilter: TorrentFilter = TorrentFilter(filtered: [], status: .all)
	
    private var updateTimer: Timer? = nil
    private var refreshInterval: TimeInterval = 5
    private var indexPromise: Promise<Void> = .value(())
    private var indexItems: Set<TorrentFile> = []
	
	init() {
		self.currentFilter = self.statusFilters.first!
        self.refreshInterval = TimeInterval(Settings.shared.refreshInterval)
        
		NotificationCenter.default.addObserver(self, selector: #selector(torrentSelectionChanged(_:)), name: .selectedTorrentsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshIntervalChanged(_:)), name: .refreshIntervalChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movingToBackground(_:)), name: NSApplication.didResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movingToForeground(_:)), name: NSApplication.didBecomeActiveNotification, object: nil)
        
        CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: nil)
	}
    
	@objc func torrentSelectionChanged(_ notification: Notification) {
		guard let torrents = notification.userInfo?["torrents"] as? [Torrent] else { return }
		
		self.selectedTorrents = torrents
		self.updateSelectedTorrent()
	}
    
    @objc func refreshIntervalChanged(_ notification: Notification) {
        self.startUpdatingTorrents()
    }
    
    @objc func movingToBackground(_ notification: Notification) {
        self.refreshInterval = TimeInterval(Settings.shared.refreshIntervalWhenMinimized)
        self.startUpdatingTorrents()
    }
    
    @objc func movingToForeground(_ notification: Notification) {
        self.refreshInterval = TimeInterval(Settings.shared.refreshInterval)
        self.startUpdatingTorrents()
    }
	
	func updateSelectedTorrent() {
		if let first = self.selectedTorrents.first {
			NotificationCenter.default.post(name: .updateSelectedTorrent, object: nil, userInfo: ["torrent": first])
//			Api.getTorrent(by: first.id).done { torrent in
//				NotificationCenter.default.post(name: .updateSelectedTorrent, object: nil, userInfo: ["torrent": torrent])
//			}
//			.catch { error in
//				print("Error receiving torrent details: ", error)
//			}
		}
	}
    
    public func startUpdatingTorrents() {
        guard Settings.shared.connection.isComplete() else { return }
        
        self.updateTorrents()
        self.updateTimer?.invalidate()
        self.updateTimer = Timer.scheduledTimer(withTimeInterval: self.refreshInterval, repeats: true) { timer in
            self.updateTorrents()
        }
    }
    
    public func stopUpdatingTorrents() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
    }
    
    public func updateTorrents() {
        Api.getTorrents().done { torrents in
            self.torrents = torrents
			self.updateFilters()
			self.updateSelectedTorrent()
            
            if self.indexPromise.isResolved {
                self.indexPromise = self.updateIndex()
            }
            
            NotificationCenter.default.post(name: .updateTorrents, object: nil, userInfo: ["torrents": self.currentFilter.filteredTorrents])
        }.catch { error in
            self.torrents = []
            self.updateFilters()
			NotificationCenter.default.post(name: .updateTorrents, object: nil, userInfo: ["torrents": self.currentFilter.filteredTorrents])
            print("Error: \(error.localizedDescription)")
        }
        
        Api.getSession().done { self.session = $0 }
            .catch { error in
                print("Error querying sesion: \(error)")
        }
    }
    
    public func updateSession() -> Promise<Void> {
        return Api.getSession().done { self.session = $0 }
    }
	
	public func updateFilters() {
		let dict = Dictionary(grouping: self.torrents, by: { $0.downloadDir })
		var dirFlt = dict.map { key, value -> TorrentFilter in
			return TorrentFilter(name: key, filtered: value, category: .downloadDirs)
        }
        dirFlt.sort { $0.name > $1.name }
        let dirChanges = self.dirFilters.merge(with: dirFlt)
		
		let all = TorrentFilter(filtered: Service.shared.torrents, status: .all)
		
		let down = Service.shared.torrents.filter { $0.getStatus() == .downloading }
		let downloading = TorrentFilter(filtered: down, status: .downloading)
		
		let completedTorrents = Service.shared.torrents.filter { $0.isFinished() }
		let completed = TorrentFilter(filtered: completedTorrents, status: .completed)
		
		let activeTorrents = Service.shared.torrents.filter { $0.isActive() }
		let active = TorrentFilter(filtered: activeTorrents, status: .active)
		
		let inactiveTorrents = Service.shared.torrents.filter { !$0.isActive() }
		let inactive = TorrentFilter(filtered: inactiveTorrents, status: .inactive)
		
		let stoppedTorrents = Service.shared.torrents.filter { $0.getStatus() == .stopped }
		let stopped = TorrentFilter(filtered: stoppedTorrents, status: .stopped)
		
		let errorTorrents = Service.shared.torrents.filter { $0.isError() }
		let error = TorrentFilter(filtered: errorTorrents, status: .error)
		
		let waitingTorrents = Service.shared.torrents.filter { [.checkWait, .downloadWait, .seedWait].contains($0.getStatus()) }
		let waiting = TorrentFilter(filtered: waitingTorrents, status: .waiting)
		
		let statFlt = [all, downloading, completed, active, inactive, stopped, error, waiting]
        let statChanges = self.statusFilters.merge(with: statFlt)
		
		let ui = ["dirChanges": dirChanges, "statChanges": statChanges]
		NotificationCenter.default.post(name: .updateFilters, object: nil, userInfo: ui)
	}
	
	public func setCurrentFilter(_ filter: TorrentFilter) {
		self.currentFilter = filter
		NotificationCenter.default.post(name: .updateTorrents, object: nil, userInfo: ["torrents": self.currentFilter.filteredTorrents])
	}
    
    private func updateIndex() -> Promise<Void> {
        let items: Set<TorrentFile> = Set(self.torrents.flatMap { $0.files }.filter { $0.downloadedPercents() == 100 })
        
        if items.count == self.indexItems.count {
            return Promise.value(())
        }
        
        let removedItems = Array(self.indexItems.subtracting(items))
        let newItemsPromises = items.subtracting(self.indexItems).map(getSerchableItem)
        
        return when(resolved: newItemsPromises).map { (results: [PromiseKit.Result<CSSearchableItem>]) -> [CSSearchableItem]  in
                return results.compactMap {
                    switch $0 {
                    case .fulfilled(let value): return value
                    case .rejected: return nil
                    }
                }
            }
            .then(on: DispatchQueue.global(), CSSearchableIndex.default().index)
            .then(on: DispatchQueue.global()) { CSSearchableIndex.default().remove(ids: removedItems.compactMap { $0.name }) }
            .done { self.indexItems = items }
    }
    
    func getSerchableItem(for file: TorrentFile) -> Promise<CSSearchableItem> {
        return Promise { seal in
            DispatchQueue.global().async {
                guard let localURL = file.startAccess() else {
                    seal.reject(CocoaError.error("Failed to get local URL of torrent file"))
                    return
                }
                
                self.searchableAttributes(for: localURL).done { attributeSet in
                    file.stopAccess()
                    let item = CSSearchableItem(uniqueIdentifier: file.name, domainIdentifier: "torrent_files", attributeSet: attributeSet)
                    seal.fulfill(item)
                }
            }
        }
    }
    
    func searchableAttributes(for url: URL) -> Guarantee<CSSearchableItemAttributeSet> {
        return Guarantee { seal in
            DispatchQueue.global().async {
                let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
                attributeSet.displayName = url.lastPathComponent
                attributeSet.contentURL = url
                
                // Detect type of file and add specific attributes
//                let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil)
//                if let uti = uti?.takeRetainedValue() {
//                    if UTTypeConformsTo(uti, kUTTypeMovie) {
//                        let asset = AVURLAsset(url: url)
//                        asset.loadValuesAsynchronously(forKeys: ["duration"]) {
//                            let seconds = CMTimeGetSeconds(asset.duration)
//                            if seconds > 0 {
//                                attributeSet.duration = NSNumber(value: seconds)
//                            }
//                            seal.fulfill(attributeSet)
//                        }
//                    } else {
//                        seal.fulfill(attributeSet)
//                    }
//                } else {
//                    seal.fulfill(attributeSet)
//                }
                
                seal(attributeSet)
            }
        }
    }
}
