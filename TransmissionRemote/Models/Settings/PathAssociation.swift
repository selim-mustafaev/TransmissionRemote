import Foundation
import DeepDiff

class PathAssociation: Codable, Mergeable {
    var localPath: String
    var remotePath: String
    var bookmark: Data?
    
    init(remote: String) {
        self.localPath = ""
        self.remotePath = remote
    }
    
    func setLocal(url: URL) {
        self.localPath = url.path
        do {
            self.bookmark = try url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch {
            print("Error reading bookmark data: ", error)
        }
    }
    
    func withLocalUrl(closure: (URL?) -> Void) {
        guard let data = self.bookmark else {
            closure(nil)
            return
        }
        
        var isStale = false
        let url = try? URL.init(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        
        if let url = url, isStale == false {
            if url.startAccessingSecurityScopedResource() {
                closure(url)
                url.stopAccessingSecurityScopedResource()
            } else {
                closure(nil)
            }
        } else {
            closure(nil)
        }
    }
    
    var diffId: Int {
        return remotePath.hashValue
    }
    
    static func compareContent(_ a: PathAssociation, _ b: PathAssociation) -> Bool {
        return a.remotePath == b.remotePath && a.localPath == b.localPath
    }
    
    func copy(from item: PathAssociation) {
        self.localPath = item.localPath
        self.remotePath = item.remotePath
        self.bookmark = item.bookmark
    }
}
