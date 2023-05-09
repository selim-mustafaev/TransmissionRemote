import Cocoa
import TransmissionRemoteCore

class MainWindowController: NSWindowController, NSWindowDelegate, NSSearchFieldDelegate {
    
    @IBOutlet weak var panelSwithcer: NSSegmentedControl!
    @IBOutlet weak var startTorrentButton: NSToolbarItem!
    @IBOutlet weak var stopTorrentButton: NSToolbarItem!
    @IBOutlet weak var removeTorrentButton: NSToolbarItem!
    
    var verticalSplit: NSSplitViewController!
    var horizontalSplit: NSSplitViewController!
    var serverDetailsPane: NSSplitViewItem!
    var torrentDetailsPane: NSSplitViewItem!
    var torrentsListController: TorrentsListController!
    var filterTask: DispatchWorkItem?

    override func windowDidLoad() {
        super.windowDidLoad()
    
        self.verticalSplit = self.window?.contentViewController as? NSSplitViewController
        self.horizontalSplit = self.verticalSplit.splitViewItems[1].viewController as? NSSplitViewController
        
        self.torrentDetailsPane = self.horizontalSplit.splitViewItems[1]
        self.serverDetailsPane = self.verticalSplit.splitViewItems[0]
        self.torrentsListController = self.horizontalSplit.splitViewItems[0].viewController as? TorrentsListController
        self.torrentDetailsPane.minimumThickness = 300
        self.torrentDetailsPane.canCollapse = true
        self.serverDetailsPane.minimumThickness = 200
        self.serverDetailsPane.canCollapse = true
        
        UserDefaults.standard.register(defaults: ["ShowServerDetails": true, "ShowTorrentDetails": false])
        
        self.serverDetailsPane.isCollapsed = !UserDefaults.standard.bool(forKey: "ShowServerDetails")
        self.torrentDetailsPane.isCollapsed = !UserDefaults.standard.bool(forKey: "ShowTorrentDetails")
        self.panelSwithcer.setSelected(!self.serverDetailsPane.isCollapsed, forSegment: 0)
        self.panelSwithcer.setSelected(!self.torrentDetailsPane.isCollapsed, forSegment: 1)
        
        self.startTorrentButton.isEnabled = false
        self.stopTorrentButton.isEnabled = false
        self.removeTorrentButton.isEnabled = false
        NotificationCenter.default.addObserver(self, selector: #selector(updateToolbarButtons(_:)), name: .selectedTorrentsChanged, object: nil)
		// TODO: Fix enabling/disabling toolbar buttons after changing state of selected torrent (without changing selection)
        NotificationCenter.default.addObserver(self, selector: #selector(updateToolbarButtons(_:)), name: .updateTorrents, object: nil)
    }

    override func awakeFromNib() {
        self.window?.setFrameAutosaveName("MainWnd")
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if Settings.shared.closingWindowQuitsApp {
            return true
        } else {
            NSApp.hide(nil)
            return false
        }
    }
    
    // MARK: - Toolbar buttons actions
    
    @objc func updateToolbarButtons(_ notification: Notification) {
        let selectedTorrents = self.torrentsListController.getSelectedTorrents()
        let stoppedCount = selectedTorrents.filter { $0.getStatus() == .stopped }.count
        self.startTorrentButton.isEnabled = stoppedCount > 0
        self.stopTorrentButton.isEnabled = stoppedCount != selectedTorrents.count
        self.removeTorrentButton.isEnabled = selectedTorrents.count > 0
    }
    
    @IBAction func showPane(_ sender: NSSegmentedControl) {
        let selected = sender.isSelected(forSegment: sender.selectedSegment)
        if sender.selectedSegment == 0 {
            self.serverDetailsPane.animator().isCollapsed = !selected
            UserDefaults.standard.set(selected, forKey: "ShowServerDetails")
        } else {
            self.torrentDetailsPane.animator().isCollapsed = !selected
            UserDefaults.standard.set(selected, forKey: "ShowTorrentDetails")
        }
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func addTorrentFile(_ sender: NSMenuItem) {
        Task { @MainActor in
            do {
                let url = try await self.selectTorrentFile()
                self.openTorrentFile(url)
            } catch {
                print("Error adding torrent: \(error)")
            }
        }
    }
    
    @IBAction func addLink(_ sender: NSMenuItem) {
        Task { @MainActor in
            do {
                let link = try await self.openAddLinkSheet()
                self.openMagnetLink(link)
            } catch {
                print("Error adding torrent: \(error)")
            }
        }
    }
    
    @IBAction func removeTorrent(_ sender: NSMenuItem) {
        self.removeSelectedTorrents(withData: false)
    }
    
    @IBAction func removeTorrentAndData(_ sender: NSMenuItem) {
        self.removeSelectedTorrents(withData: true)
    }
    
    @IBAction func startTorrents(_ sender: NSToolbarItem) {
        Task { @MainActor in
            let selectedTorrents = self.torrentsListController.getSelectedTorrents()
            try? await Api.startTorrents(by: selectedTorrents.map { $0.id })
            await Service.shared.updateTorrents()
        }
    }
    
    @IBAction func stopTorrents(_ sender: NSToolbarItem) {
        Task { @MainActor in
            let selectedTorrents = self.torrentsListController.getSelectedTorrents()
            try? await Api.stopTorrents(by: selectedTorrents.map { $0.id })
            await Service.shared.updateTorrents()
        }
    }
    
    // MARK: - Utils
    
    func selectTorrentFile() async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            guard let wnd = self.window else {
                continuation.resume(throwing: CocoaError.error("self.window is nil"))
                return
            }
            
            let panel = NSOpenPanel()
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.canCreateDirectories = false
            panel.allowsMultipleSelection = false
            panel.allowedFileTypes = ["torrent"]
            
            panel.beginSheetModal(for: wnd) { response in
                if response == .OK {
                    if let url = panel.url {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: CocoaError.error("File URL not found"))
                    }
                } else {
                    continuation.resume(throwing: CocoaError.cancelError())
                }
            }
        }
    }
    
    func openAddLinkSheet() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let addLinkController = AddLinkController(nibName: "AddLinkController", bundle: nil)
            addLinkController.onOk = { url in
                continuation.resume(returning: url)
            }
            addLinkController.onCancel = {
                continuation.resume(throwing: CocoaError.cancelError())
            }
            self.window?.contentViewController?.presentAsSheet(addLinkController)
        }
    }
    
    func openAddTorrentSheet(source: Torrent.Source) {
        let addController = AddTorrentController(nibName: "AddTorrentController", bundle: nil)
        addController.source = source
        self.window?.contentViewController?.presentAsSheet(addController)
    }
    
    func removeSelectedTorrents(withData: Bool) {
        Task { @MainActor in
            let selectedTorrents = self.torrentsListController.getSelectedTorrents()
            try? await Api.removeTorrents(by: selectedTorrents.map { $0.id }, deleteData: withData)
            await Service.shared.updateTorrents()
        }
    }
    
    func openMagnetLink(_ link: String) {
        self.openAddTorrentSheet(source: .link(link))
    }
    
    func openTorrentFile(_ url: URL) {
        self.openAddTorrentSheet(source: .file(url))
    }
	
	func hideDetailsPanel() {
		self.panelSwithcer.setSelected(false, forSegment: 1)
		self.showPane(self.panelSwithcer)
	}
    
    // MARK: - Filtering torrent list
    
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
        self.torrentsListController.filterTorrents(with: "")
    }
    
    func controlTextDidChange(_ obj: Notification) {
        guard let editor = obj.userInfo?["NSFieldEditor"] as? NSTextView else { return }
        guard editor.string.count > 0 else { return }
        
        self.filterTask?.cancel()
        self.filterTask = DispatchWorkItem {
            self.torrentsListController.filterTorrents(with: editor.string)
        }
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5, execute: self.filterTask!)
    }
}
