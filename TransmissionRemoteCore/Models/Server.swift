import Foundation

public struct Server: Decodable {
    public let version: String
    public let downloadDir: String
    public let peerLimitPerTorrent: Int
    public let incompleteDirEnabled: Bool
    public let incompleteDir: String
    public let freeSpace: Int64
    
    enum CodingKeys: String, CodingKey {
        case version
        case downloadDir = "download-dir"
        case peerLimitPerTorrent = "peer-limit-per-torrent"
        case incompleteDirEnabled = "incomplete-dir-enabled"
        case incompleteDir = "incomplete-dir"
        case freeSpace = "download-dir-free-space"
    }
}
