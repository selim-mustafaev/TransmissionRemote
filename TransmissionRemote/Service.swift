import Foundation
import Cocoa
import PromiseKit

class Service {
    static let shared = Service()
    
    private(set) var torrents: [Torrent] = []
	private(set) var selectedTorrents: [Torrent] = []
    private(set) var session: Server? = nil
	private(set) var statusFilters: [TorrentFilter] = StatusFilter.allCases.map { TorrentFilter(filtered: [], status: $0) }
	private(set) var dirFilters: [TorrentFilter] = []
	private(set) var trackerFilters:[TorrentFilter] = []
	private(set) var currentFilter: TorrentFilter = TorrentFilter(filtered: [], status: .all)
	
    private var updateTimer: Timer? = nil
    private var refreshInterval: TimeInterval = 5
	
	init() {
		self.currentFilter = self.statusFilters.first!
        self.refreshInterval = TimeInterval(Settings.shared.refreshInterval)
        
		NotificationCenter.default.addObserver(self, selector: #selector(torrentSelectionChanged(_:)), name: .selectedTorrentsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshIntervalChanged(_:)), name: .refreshIntervalChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movingToBackground(_:)), name: NSApplication.didResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(movingToForeground(_:)), name: NSApplication.didBecomeActiveNotification, object: nil)
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
    
    func startUpdatingTorrents() {
        guard Settings.shared.connection.isComplete() else { return }
        
        self.updateTorrents()
        self.updateTimer?.invalidate()
        self.updateTimer = Timer.scheduledTimer(withTimeInterval: self.refreshInterval, repeats: true) { timer in
            self.updateTorrents()
        }
    }
    
    func stopUpdatingTorrents() {
        self.updateTimer?.invalidate()
        self.updateTimer = nil
    }
    
    func updateTorrents() {
        Api.getTorrents().done { torrents in
            self.torrents = torrents
			self.updateFilters()
			self.updateSelectedTorrent()
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
    
    func updateSession() -> Promise<Void> {
        return Api.getSession().done { self.session = $0 }
    }
	
	func updateFilters() {
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
	
	func setCurrentFilter(_ filter: TorrentFilter) {
		self.currentFilter = filter
		NotificationCenter.default.post(name: .updateTorrents, object: nil, userInfo: ["torrents": self.currentFilter.filteredTorrents])
	}
}
