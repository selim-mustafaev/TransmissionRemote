import Foundation

public enum TorrentError: Error {
    case general(description: String, suggestion: String)
    case localPathNotFound(torrentName: String, localPath: String)
    case associationNotFound(torrentName: String)
}
