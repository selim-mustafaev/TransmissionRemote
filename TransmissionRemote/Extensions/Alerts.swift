import Cocoa

extension NSAlert {
    
    static func showError(_ text: String, suggestion: String, for window: NSWindow) {
        let alert = NSAlert()
        alert.messageText = text
        alert.informativeText = suggestion
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
    
    static func showError(_ error: Error, for window: NSWindow) {
        let alert = NSAlert(error: error)
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
    
    static func showError(_ text: String, suggestion: String, openSettings pane: String, for window: NSWindow) {
        let alert = NSAlert()
        alert.messageText = text
        alert.informativeText = suggestion
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Open Settings")
        alert.beginSheetModal(for: window) { response in
            if response == .alertSecondButtonReturn {
                let sb = NSStoryboard(name: "Settings", bundle: nil)
                let controller = sb.instantiateInitialController() as? NSWindowController
                let tabController = controller?.contentViewController as? NSTabViewController
                tabController?.tabView.selectTabViewItem(withIdentifier: pane)
                controller?.showWindow(nil)
            }
        }
    }
}
