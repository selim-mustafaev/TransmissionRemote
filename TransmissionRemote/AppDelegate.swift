import Cocoa
import TransmissionRemoteCore
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var columnsMenu: NSMenuItem!
    @IBOutlet weak var statusMenu: NSMenu!
    
    var appLaunched = false
    var magnetLinkToOpen: String? = nil
    var torrentFileToOpen: String? = nil
    var statusItem: NSStatusItem!
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(self, andSelector: #selector(AppDelegate.handleGetURLEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if Settings.shared.connection.isComplete() {
            Service.shared.updateSession().done {
                Service.shared.startUpdatingTorrents()
                if  let link = self.magnetLinkToOpen,
                    let wndController = NSApplication.shared.mainWindow?.windowController as? MainWindowController
                {
                    wndController.openMagnetLink(link)
                }
                
                if  let filename = self.torrentFileToOpen,
                    let wndController = NSApplication.shared.mainWindow?.windowController as? MainWindowController
                {
                    wndController.openTorrentFile(URL(fileURLWithPath: filename))
                }
            }.catch { error in
                print("Error updating session: \(error)")
            }
		} else {
			self.openConnectionSettings()
		}
        
        NotificationCenter.default.addObserver(self, selector: #selector(connectionSettingsUpdated(_:)), name: .connectionSettingsUpdated, object: nil)
        
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        let icon = NSImage(named: "menubar_icon")
        statusItem.image = icon
        statusItem.menu = self.statusMenu
		
		if #available(OSX 10.14, *) {
			UNUserNotificationCenter.current().registerNotificationCategories()
			UNUserNotificationCenter.current().delegate = self
		}
        
        self.appLaunched = true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        if self.appLaunched, let wndController = NSApplication.shared.windows.first?.windowController as? MainWindowController {
            NSApp.activate(ignoringOtherApps: true)
            wndController.openTorrentFile(URL(fileURLWithPath: filename))
        } else {
            self.torrentFileToOpen = filename
        }
        return true
    }
    
    func application(_ sender: NSApplication, openTempFile filename: String) -> Bool {
        if self.appLaunched, let wndController = NSApplication.shared.windows.first?.windowController as? MainWindowController {
            NSApp.activate(ignoringOtherApps: true)
            wndController.openTorrentFile(URL(fileURLWithPath: filename))
        } else {
            self.torrentFileToOpen = filename
        }
        return true
    }
    
    @objc func handleGetURLEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else { return }
        guard urlString.starts(with: "magnet:") else { return }
        
        if self.appLaunched, let wndController = NSApplication.shared.windows.first?.windowController as? MainWindowController {
            NSApp.activate(ignoringOtherApps: true)
            wndController.openMagnetLink(urlString)
        } else {
            self.magnetLinkToOpen = urlString
        }
    }
    
    @objc func connectionSettingsUpdated(_ notification: Notification) {
        if Settings.shared.connection.isComplete() {
            Service.shared.updateSession().done(Service.shared.startUpdatingTorrents).catch { error in
                print("Error updating session: \(error)")
            }
        }
    }
	
	func openConnectionSettings() {
		let sb = NSStoryboard(name: "Settings", bundle: nil)
		let controller = sb.instantiateInitialController() as? NSWindowController
		let tabController = controller?.contentViewController as? NSTabViewController
		tabController?.tabView.selectTabViewItem(withIdentifier: "Connection")
		controller?.showWindow(self)
	}
    
    // MARK: - Menubar button
    
    @IBAction func openMainWindow(_ sender: NSMenuItem) {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func startAllTorrents(_ sender: NSMenuItem) {
        Api.startTorrents(by: Service.shared.torrents.map { $0.id }).catch { error in
            print("Starting all torrents failed: ", error)
        }
    }
    
    @IBAction func stopAllTorrents(_ sender: NSMenuItem) {
        Api.stopTorrents(by: Service.shared.torrents.map { $0.id }).catch { error in
            print("Stopping all torrents failed: ", error)
        }
    }
    
    @IBAction func quitApp(_ sender: NSMenuItem) {
        NSApp.terminate(nil)
    }
	
	// MARK: - Notifications
	
	@available(OSX 10.14, *)
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
	{
		if response.actionIdentifier == NotificationAction.revealInFinder.rawValue {
			if let torrentId = response.notification.request.content.userInfo["torrentId"] as? Int,
				let torrent = Service.shared.torrents.first(where: { $0.differenceIdentifier == torrentId })
			{
				torrent.withLocalPath { path, error in
					if let path = path {
						NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
					} else if let error = error {
						error.displayAlert(for: nil)
					} else {
						NSAlert.showError("Cannot open torrent", suggestion: "Unknown error", for: nil)
					}
				}
			}
		}
	}
}

