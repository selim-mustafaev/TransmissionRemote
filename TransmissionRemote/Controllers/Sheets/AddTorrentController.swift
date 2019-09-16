import Cocoa
import PromiseKit
import TransmissionRemoteCore

class AddTorrentController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    @IBOutlet weak var grid: NSGridView!
    @IBOutlet weak var savAsField: NSTextField!
    @IBOutlet weak var peerLimitField: NSTextField!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var destination: NSComboBox!
    
    var source: Torrent.Source!
    
    private var torrent: Torrent?
    private var filesTree: TreeNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.grid.cell(for: self.savAsField)?.row?.mergeCells(in: NSMakeRange(1,2))
        self.grid.cell(for: self.peerLimitField)?.row?.mergeCells(in: NSMakeRange(1,2))
        
        self.peerLimitField.integerValue = Service.shared.session?.peerLimitPerTorrent ?? 20
        
        self.parseTorrent(source: self.source)
            .done { torrent in
                self.torrent = torrent
                self.savAsField.stringValue = self.torrent?.name ?? ""
                if let files = self.torrent?.files {
                    self.filesTree = self.generateTree(from: files)
                    self.calcSizes(for: self.filesTree)
                    self.outlineView.reloadData()
                }
            }.catch { error in
                if let wnd = self.view.window {
                    NSAlert.showError(error, for: wnd)
                    self.dismiss(nil)
                }
            }
    }
    
    override func viewWillAppear() {
        NotificationCenter.default.addObserver(self, selector: #selector(torrentsUpdated(_:)), name: .updateTorrents, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFiles(_:)), name: .updateFileState, object: nil)
    }
    
    override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func torrentsUpdated(_ notification: Notification) {
        if self.destination.numberOfItems == 0 {
            self.destination.addItems(withObjectValues: Service.shared.dirFilters.map { $0.name })
            self.destination.selectItem(at: 0)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func okAction(_ sender: NSButton) {
        guard let torrent = self.torrent else { return }
        
        let files = torrent.files
        var wanted: [Int] = []
        var unwanted: [Int] = []
        for (index, file) in files.enumerated() {
            if file.enabled {
                wanted.append(index)
            } else {
                unwanted.append(index)
            }
        }
        
        var addPromise = Api.addTorrent(from: self.source, location: self.destination.stringValue, maxPeers: self.peerLimitField.integerValue, wanted: wanted, unwanted: unwanted, start: true)
        
        if self.savAsField.stringValue != torrent.name {
            addPromise = addPromise.then { id in
                return Api.rename(path: torrent.name, to: self.savAsField.stringValue, in: id).map { id }
            }
        }

        addPromise.done { _ in
            Service.shared.updateTorrents()
            self.dismiss(nil)
        }
        .catch { error in
            self.dismiss(nil)
            if let wnd = self.view.window {
                NSAlert.showError(error, for: wnd)
            }
        }
        
        
    }
    
    @IBAction func cancelAction(_ sender: NSButton) {
        self.dismiss(nil)
    }
    
    @IBAction func browse(_ sender: NSButton) {
        guard let wnd = self.view.window else { return }
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.allowsMultipleSelection = false
        panel.beginSheetModal(for: wnd) { response in
            if response == .OK {
                if let url = panel.url {
                    for index in Settings.shared.pathAssociations.indices {
                        if url.path.starts(with: Settings.shared.pathAssociations[index].localPath) {
                            let remotePath = url.path.replacingOccurrences(of: Settings.shared.pathAssociations[index].localPath, with: Settings.shared.pathAssociations[index].remotePath)
                            self.destination.stringValue = remotePath
                            return
                        }
                    }
                    
                    NSAlert.showError("Path selection error", suggestion: "Cannot find remote path associated with selected local path", for: wnd)
                }
            }
        }
    }
    
    // MARK: - NSOutlineViewDataSource
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard self.filesTree != nil else { return 0 }
        
        if item == nil {
            return self.filesTree.children.count
        }
        
        if let node = item as? TreeNode {
            return node.children.count
        } else {
            return 0
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return self.filesTree.children[index]
        }
        
        if let node = item as? TreeNode {
            return node.children[index]
        } else {
            return TreeNode(name: "<Error>", size: 0)
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let node = item as? TreeNode {
            return node.children.count > 0
        } else {
            return false
        }
    }
    
    // MARK: - NSOutlineViewDelegate
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let node = item as? TreeNode else { return nil }
        var cell: NSTableCellView? = nil
        
        if tableColumn?.identifier == .addTorrentFileName {
            let fscell = outlineView.makeView(withIdentifier: .fileName, owner: nil) as? CheckedFsItemCell
            fscell?.configure(with: node)
            cell = fscell
        } else if tableColumn?.identifier == .addTorrentFileSize {
            cell = outlineView.makeView(withIdentifier: .fileSize, owner: nil) as? NSTableCellView
            let formatter = ByteCountFormatter()
            formatter.countStyle = .file
            cell?.textField?.stringValue = formatter.string(fromByteCount: Int64(node.size))
        }
        
        return cell
    }
    
    // MARK: - Notification handlers
    
    @objc func updateFiles(_ notification: Notification) {
        guard let node = notification.userInfo?["node"] as? TreeNode else { return }
        
        var nodes: [TreeNode] = []
        var curNode = node
        while true {
            if let parent = curNode.parent {
                nodes.append(parent)
                curNode = parent
            } else {
                break
            }
        }
        
        self.outlineView.beginUpdates()
        self.outlineView.reloadItem(node, reloadChildren: true)
        for item in nodes {
            self.outlineView.reloadItem(item, reloadChildren: false)
        }
        self.outlineView.endUpdates()
    }
    
    // MARK: - Utils
    
    func generateTree(from list: [TorrentFile]) -> TreeNode {
        var root = TreeNode(name: "", size: 0)
        for file in list {
            let items = file.name.split(separator: "/")
            if items.count == 1 {
                let child = TreeNode(name: String(items.first!), size: file.length)
                child.file = file
                root.addChild(child)
            } else {
                var curNode = root
                for (index, item) in items.enumerated() {
                    if index == items.count - 1 {
                        let child = TreeNode(name: String(item), size: file.length)
                        child.file = file
                        curNode.addChild(child)
                    } else {
                        if let dir = curNode.children.first(where: { $0.name == String(item) }) {
                            curNode = dir
                        } else {
                            let newDir = TreeNode(name: String(item), size: 0)
                            curNode.addChild(newDir)
                            curNode = newDir
                        }
                    }
                }
            }
        }
        
        if root.children.count == 1 && root.children.first!.children.count > 0 {
            root = root.children.first!
        }
        
        return root
    }
    
    func calcSizes(for tree: TreeNode) {
        tree.size = tree.children.reduce(0) { acc, node in
            if !node.isLeaf {
                self.calcSizes(for: node)
            }
            return acc + node.size
        }
    }
    
    func parseTorrentFile(url: URL) -> Promise<Torrent> {
        return Promise { seal in
            DispatchQueue.global().async {
                let bencode = Bencode(file: url)
                guard let info = bencode?["info"], let name = info["name"].string else {
                    seal.reject(CocoaError.error("Error opening torrent file", suggestion: "Failed to find info section"))
                    return
                }
                
                var files: [TorrentFile] = []
                if let list = info["files"].list {
                    for fileInfo in list {
                        if let length = fileInfo["length"].int, let pathList = fileInfo["path"].list {
                            let path = pathList.map { $0.string ?? "" }.joined(separator: "/")
                            files.append(TorrentFile(name: path, length: Int64(length)))
                        }
                    }
                } else {
                    files.append(TorrentFile(name: name, length: Int64(info["length"].int ?? 0)))
                }
                
                seal.fulfill(Torrent(name: name, files: files))
            }
        }
    }
    
    func parseTorrent(source: Torrent.Source) -> Promise<Torrent> {
        switch source {
        case .file(let url):
            return self.parseTorrentFile(url: url)
        case .link(let link):
            if let magnet = Magnet(link) {
                return Promise.value(Torrent(name: magnet.dn, files: []))
            } else {
                return Promise(error: CocoaError.error("Error parsing magnet link"))
            }
        }
    }
}
