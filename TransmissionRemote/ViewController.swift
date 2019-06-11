import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var bottomView: NSView!
    @IBOutlet weak var mainView: NSView!
    
    @IBOutlet weak var verticalSplit: NSSplitView!
    @IBOutlet weak var horizontalSplit: NSSplitView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.leftView.wantsLayer = true
        self.mainView.wantsLayer = true
        self.leftView.layer?.backgroundColor = NSColor.green.cgColor
        self.mainView.layer?.backgroundColor = NSColor.red.cgColor
    }
}

