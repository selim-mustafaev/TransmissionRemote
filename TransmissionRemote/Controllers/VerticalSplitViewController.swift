import Cocoa

class VerticalSplitViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func awakeFromNib() {
        self.splitView.autosaveName = "VSplit"
    }
}
