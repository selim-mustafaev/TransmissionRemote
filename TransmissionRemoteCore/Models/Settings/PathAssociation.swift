import Foundation
import DeepDiff

public class PathAssociation: Codable, Mergeable {
    public var localPath: String
    public var remotePath: String
    private var bookmark: Data?
    
    public init(remote: String) {
        self.localPath = ""
        self.remotePath = remote
    }
    
    public func setLocal(url: URL) {
        self.localPath = url.path
        do {
            self.bookmark = try url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil)
        } catch {
            print("Error reading bookmark data: ", error)
        }
    }
    
    public func withLocalUrl(closure: (URL?) -> Void) {
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
    
    public func securityScopedURL() -> URL? {
        guard let data = self.bookmark else { return nil }
        
        var isStale = false
        let url = try? URL.init(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        
        if isStale {
            return nil
        }
        
        return url
    }
    
    public var diffId: Int {
        return remotePath.hashValue
    }
    
    public static func compareContent(_ a: PathAssociation, _ b: PathAssociation) -> Bool {
        return a.remotePath == b.remotePath && a.localPath == b.localPath
    }
    
    public func copy(from item: PathAssociation) {
        self.localPath = item.localPath
        self.remotePath = item.remotePath
        self.bookmark = item.bookmark
    }
}
