import Cocoa

extension NSAlert {
    
    static func showError(_ text: String, suggestion: String, for window: NSWindow?) {
        let alert = NSAlert()
        alert.messageText = text
        alert.informativeText = suggestion
        alert.addButton(withTitle: "OK")
		
		if let wnd = window {
			alert.beginSheetModal(for: wnd, completionHandler: nil)
		} else {
			alert.runModal()
		}
    }
    
    static func showError(_ error: Error, for window: NSWindow?) {
        let alert = NSAlert(error: error)
		
		if let wnd = window {
			alert.beginSheetModal(for: wnd, completionHandler: nil)
		} else {
			alert.runModal()
		}
    }
    
    static func showError(_ text: String, suggestion: String, openSettings pane: String, for window: NSWindow?) {
		guard let wnd = window else { return }
		
        let alert = NSAlert()
        alert.messageText = text
        alert.informativeText = suggestion
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Open Settings")
        alert.beginSheetModal(for: wnd) { response in
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
