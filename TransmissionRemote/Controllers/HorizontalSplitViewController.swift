import Cocoa

class HorizontalSplitViewController: NSSplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func awakeFromNib() {
        self.splitView.autosaveName = "HSplit"
    }
}
