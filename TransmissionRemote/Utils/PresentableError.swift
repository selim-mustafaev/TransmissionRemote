import Cocoa
import TransmissionRemoteCore

protocol PresentableError: Error {
    func displayAlert(for window: NSWindow)
}

extension TorrentError: PresentableError {
    func displayAlert(for window: NSWindow) {
        switch self {
        case .general(let description, let suggestion):
            NSAlert.showError(description, suggestion: suggestion, for: window)
        case .localPathNotFound(let torrentName, let localPath):
            NSAlert.showError("Cannot open torrent", suggestion: "Error opening local path (\(localPath)) for the torrent: \(torrentName). Check if settings contain valid path mapping", openSettings: "Paths", for: window)
        case .associationNotFound(let torrentName):
            NSAlert.showError("Cannot open torrent", suggestion: "Cannot find any path mapping for the torrent: \(torrentName). You can add new mapping in settings.", openSettings: "Paths", for: window)
        }
    }
}
