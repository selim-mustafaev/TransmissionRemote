import Foundation
import UserNotifications

public enum NotificationCategory: String {
	case torrentDownloaded = "TorrentDownloadedCategory"
}

public enum NotificationAction: String {
	case revealInFinder = "RevealInFinderAction"
}

@available(OSX 10.14, *)
public extension UNUserNotificationCenter {
	
	internal func showNotification(title: String, body: String, category: NotificationCategory, info: [AnyHashable: Any]) {
		self.requestAuthorization(options: [.sound]) { granted, error in
				if granted {
					let content = UNMutableNotificationContent()
					content.title = title
					content.body = body
					content.sound = .default
					content.categoryIdentifier = category.rawValue
					content.userInfo = info
					
					let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
					let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
					self.add(request)
				}
		}
	}
	
	func showDownloadedNotification(for torrent: Torrent) {
		self.showNotification(title: "Torrent download finished",
							  body: torrent.name,
							  category: .torrentDownloaded,
							  info: ["torrentId": torrent.differenceIdentifier])
	}
	
	func registerNotificationCategories() {
		let revealAction = UNNotificationAction(identifier: NotificationAction.revealInFinder.rawValue, title: "Reveal in Finder", options: [])
		let category = UNNotificationCategory(identifier: NotificationCategory.torrentDownloaded.rawValue, actions: [revealAction], intentIdentifiers: [], options: [])
		self.setNotificationCategories([category])
	}
}
