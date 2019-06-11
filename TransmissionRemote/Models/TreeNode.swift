import Cocoa

class TreeNode {
    var name: String = ""
    var size: Int64 = 0
    var state: NSControl.StateValue = .on {
        didSet {
            if self.state != .mixed {
                self.file?.enabled = self.state == .on
            }
        }
    }
    var file: TorrentFile?
    
    weak var parent: TreeNode?
    var children = [TreeNode]()
    
    var isLeaf: Bool {
        return children.count == 0
    }
    
    init(_ value: TorrentFile) {
        self.name = value.name
        self.size = value.length
    }
    
    init(name: String, size: Int64) {
        self.name = name
        self.size = size
    }
    
    func addChild(_ node: TreeNode) {
        children.append(node)
        node.parent = self
        self.size += node.size
    }
    
    func recalculateState() {
        if self.children.count > 0 {
            var onChildren = 0
            var mixedChildren = 0
            for node in self.children {
                if node.state == .on {
                    onChildren += 1
                } else if node.state == .mixed {
                    mixedChildren += 1
                }
            }

            if onChildren == 0 && mixedChildren == 0 {
                self.state = .off
            } else if onChildren == self.children.count {
                self.state = .on
            } else {
                self.state = .mixed
            }
        }
        
        self.parent?.recalculateState()
    }
    
    func propagateStateDown() {
        if self.state != .mixed {
            for node in self.children {
                node.state = self.state
                node.propagateStateDown()
            }
        }
    }
    
    func setState(_ newState: NSControl.StateValue) {
        self.state = newState
        self.propagateStateDown()
        self.parent?.recalculateState()
    }
}
