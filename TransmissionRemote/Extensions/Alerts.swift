import Cocoa

extension NSAlert {
    
    static func showError(_ text: String, description: String, for window: NSWindow) {
        let alert = NSAlert()
        alert.messageText = text
        alert.informativeText = description
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
    
    static func showError(_ error: Error, for window: NSWindow) {
        let alert = NSAlert(error: error)
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
}
