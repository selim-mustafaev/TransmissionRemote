import Foundation

extension Notification.Name {
    static let selectedTorrentsChanged = Notification.Name("SelectedTorrentsChanged")
    static let updateFileState = Notification.Name("UpdateFileState")
    static let connectionSettingsUpdated = Notification.Name("ConnectionSettingsUpdated")
    static let updateTorrents = Notification.Name("UpdateTorrents")
    static let updateFilters = Notification.Name("UpdateFilters")
    static let updateSelectedTorrent = Notification.Name("UpdateSelectedTorrent")
    static let refreshIntervalChanged = Notification.Name("RefreshIntervalChanged")
}
