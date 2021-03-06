import Cocoa

public class TreeNode {
    public var name: String = ""
    public var size: Int64 = 0
    public var state: NSControl.StateValue = .on {
        didSet {
            if self.state != .mixed {
                self.file?.enabled = self.state == .on
            }
        }
    }
    public var file: TorrentFile?
    
    public weak var parent: TreeNode?
    public var children = [TreeNode]()
    
    public var isLeaf: Bool {
        return children.count == 0
    }
    
    public init(_ value: TorrentFile) {
        self.name = value.name
        self.size = value.length
    }
    
    public init(name: String, size: Int64) {
        self.name = name
        self.size = size
    }
    
    public func addChild(_ node: TreeNode) {
        children.append(node)
        node.parent = self
        self.size += node.size
    }
    
    public func recalculateState() {
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
    
    public func propagateStateDown() {
        if self.state != .mixed {
            for node in self.children {
                node.state = self.state
                node.propagateStateDown()
            }
        }
    }
    
    public func setState(_ newState: NSControl.StateValue) {
        self.state = newState
        self.propagateStateDown()
        self.parent?.recalculateState()
    }
}
