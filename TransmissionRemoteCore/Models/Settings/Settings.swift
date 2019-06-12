import Foundation

public class Settings {
    private static let defaults = UserDefaults.standard
    public static let shared = Settings()
    
    public var connection: Connection = Connection() {
        didSet {
            if let json = try? JSONEncoder().encode(self.connection) {
                Settings.defaults.set(json, forKey: "connection")
                Settings.defaults.synchronize()
            }
        }
    }
    
    public var authRequired: Bool = false {
        didSet {
            Settings.defaults.set(self.authRequired, forKey: "authRequired")
            Settings.defaults.synchronize()
        }
    }
    
    public var refreshInterval: Int = 0 {
        didSet {
            Settings.defaults.set(self.refreshInterval, forKey: "refreshInterval")
            Settings.defaults.synchronize()
        }
    }
    
    public var refreshIntervalWhenMinimized: Int = 0 {
        didSet {
            Settings.defaults.set(self.refreshInterval, forKey: "refreshIntervalWhenMinimized")
            Settings.defaults.synchronize()
        }
    }
    
    public var deleteTorrentFile: Bool = false {
        didSet {
            Settings.defaults.set(self.refreshInterval, forKey: "deleteTorrentFile")
            Settings.defaults.synchronize()
        }
    }
    
    public var pathAssociations: [PathAssociation] = [] {
        didSet {
            if let json = try? JSONEncoder().encode(self.pathAssociations) {
                Settings.defaults.set(json, forKey: "pathAssociations")
                Settings.defaults.synchronize()
            }
        }
    }
    
    public var torrentColumns: [String] = [] {
        didSet {
            Settings.defaults.set(self.torrentColumns, forKey: "torrentColumns")
            Settings.defaults.synchronize()
        }
    }
    
    public var closingWindowQuitsApp: Bool = true {
        didSet {
            Settings.defaults.set(self.closingWindowQuitsApp, forKey: "ClosingWindowQuitsApp")
            Settings.defaults.synchronize()
        }
    }
    
    init() {
        UserDefaults.standard.register(defaults: [
            "authRequired": false,
            "refreshInterval": 5,
            "refreshIntervalWhenMinimized": 20,
            "deleteTorrentFile": false,
            "torrentColumns": ["Name", "Size", "Progress", "Seeds", "Peers", "DownSpeed", "UpSpeed", "Eta", "Ratio"],
            "ClosingWindowQuitsApp": true
        ])
        
        self.connection = Settings.getConnection()
        self.authRequired = Settings.defaults.bool(forKey: "authRequired")
        self.refreshInterval = Settings.defaults.integer(forKey: "refreshInterval")
        self.refreshIntervalWhenMinimized = Settings.defaults.integer(forKey: "refreshIntervalWhenMinimized")
        self.deleteTorrentFile = Settings.defaults.bool(forKey: "deleteTorrentFile")
        self.pathAssociations = Settings.getPathAssociations()
        self.torrentColumns = (Settings.defaults.array(forKey: "torrentColumns") as? [String]) ?? []
        self.closingWindowQuitsApp = Settings.defaults.bool(forKey: "ClosingWindowQuitsApp")
    }
    
    private static func getConnection() -> Connection {
        guard let data = Settings.defaults.data(forKey: "connection") else { return Connection() }
        return (try? JSONDecoder().decode(Connection.self, from: data)) ?? Connection()
    }
    
    private static func getPathAssociations() -> [PathAssociation] {
        guard let data = Settings.defaults.data(forKey: "pathAssociations") else { return [] }
        return (try? JSONDecoder().decode([PathAssociation].self, from: data)) ?? []
    }
}
