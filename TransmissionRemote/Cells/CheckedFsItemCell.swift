import Cocoa

class CheckedFsItemCell: NSTableCellView {

    @IBOutlet weak var imgView: NSImageView!
    @IBOutlet weak var checkButton: NSButton!
    
    var node: TreeNode?
    
    func configure(with node: TreeNode) {
        self.node = node
        self.checkButton.allowsMixedState = !node.isLeaf
        self.checkButton.title = node.name
        self.checkButton.state = node.state
        
        if !node.isLeaf {
            self.imgView.image = NSImage(named: NSImage.Name("NSFolder"))
        } else {
            let components = node.name.split(separator: ".")
            if components.count > 1, let ext = components.last {
                self.imgView.image = NSWorkspace.shared.icon(forFileType: String(ext))
            } else {
                self.imgView.image = nil
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.node = nil
        self.imgView.image = nil
    }
    
    @IBAction func checkAction(_ sender: NSButton) {
        guard let node = self.node else { return }
        
        node.setState(sender.state)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .updateFileState, object: nil, userInfo: ["node": node])
        }
    }
}
