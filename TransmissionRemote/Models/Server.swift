import Foundation

struct Server: Decodable {
    let version: String
    let downloadDir: String
    let peerLimitPerTorrent: Int
    let incompleteDirEnabled: Bool
    let incompleteDir: String
    let freeSpace: Int64
    
    enum CodingKeys: String, CodingKey {
        case version
        case downloadDir = "download-dir"
        case peerLimitPerTorrent = "peer-limit-per-torrent"
        case incompleteDirEnabled = "incomplete-dir-enabled"
        case incompleteDir = "incomplete-dir"
        case freeSpace = "download-dir-free-space"
    }
}
