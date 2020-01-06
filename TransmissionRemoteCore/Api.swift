import Foundation
import PromiseKit
import PMKFoundation
import OHHTTPStubs

public class Api {
    private static var sessionId = UserDefaults.standard.string(forKey: "SessionID") ?? ""
    private static let queue = DispatchQueue(label: "ApiQueriesQueue")
    
    private static func genError(_ msg: String, suggestion: String, code: Int = 0) -> Error {
        return NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: msg, NSLocalizedRecoverySuggestionErrorKey: suggestion])
    }
    
    private static func createRequest(method: String, arguments: [String: Any]?) -> Promise<URLRequest> {
        guard let url = Settings.shared.connection.url() else {
            return Promise(error: self.genError("Network error", suggestion: "Network request failed"))
        }
        
        return Promise { seal in
            self.queue.async {
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue(self.sessionId, forHTTPHeaderField: "X-Transmission-Session-Id")
                
                var body: [String: Any] = ["method": method]
                if let args = arguments {
                    body["arguments"] = args
                }
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                seal.fulfill(request)
            }
        }
    }
    
    private static func make<T>(_ request: URLRequest) -> Promise<T> where T: Codable {
        return URLSession.shared.dataTask(.promise, with: request).then(on: self.queue) { data, response -> Promise<T> in
            guard let response = response as? HTTPURLResponse else { return Promise(error: self.genError("Network error", suggestion: "Unknown response type")) }
            guard response.statusCode != 409 else {
                if let idHeader = response.allHeaderFields["X-Transmission-Session-Id"] as? String {
                    self.sessionId = idHeader
                    UserDefaults.standard.set(idHeader, forKey: "SessionID")
                    UserDefaults.standard.synchronize()
                    return self.createRequest(method: "", arguments: nil).map { newRequest in
                        var requestCopy = newRequest
                        requestCopy.httpBody = request.httpBody
                        return requestCopy
                    }
                    .then(on: self.queue, self.make)
                } else {
                    return Promise(error: self.genError("Network error", suggestion: "Getting session failed"))
                }
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                return Promise(error: self.genError("Network error", suggestion: "Getting session failed"))
            }
            
            do {
				let str = String(data: data, encoding: .utf8)
				print("=============================================================")
				print(str ?? "")
                let jsonResp = try JSONDecoder().decode(Response<T>.self, from: data)
                if jsonResp.result != "success" {
                    return Promise(error: self.genError("Decoding error", suggestion: jsonResp.result))
                } else {
                    return Promise.value(jsonResp.arguments)
                }
            } catch {
				print(error)
                return Promise(error: self.genError("Decoding error", suggestion: "Decoding torrents info failed"))
            }
        }
    }
    
    // MARK: - Transmission RPC wrappers
    
    private static let torrentFields = [
        "id",
        "name",
        "status",
        "errorString",
        "sizeWhenDone",
        "leftUntilDone",
        "rateDownload",
        "rateUpload",
        "metadataPercentComplete",
        "totalSize",
        "peersSendingToUs",
        "seeders",
        "peersGettingFromUs",
        "leechers",
        "eta",
        "uploadRatio",
        "downloadDir",
		"pieceCount",
		"pieceSize",
		"pieces",
		"comment",
		"addedDate",
		"doneDate",
		"downloadedEver",
		"downloadLimit",
		"downloadLimited",
		"uploadedEver",
		"uploadLimit",
		"uploadLimited",
		"maxConnectedPeers",
		"activityDate",
		"trackerStats",
		"peers",
		"files",
		"priorities",
        "wanted",
        "bandwidthPriority",
        "queuePosition",
        "secondsSeeding"
    ]
    
    public static func getSession() -> Promise<Server> {
        return self.createRequest(method: "session-get", arguments: nil).then(on: self.queue, self.make)
    }
    
    public static func getTorrents() -> Promise<[Torrent]> {
        let arguments = [
            "fields": self.torrentFields
        ]
        
        return self.createRequest(method: "torrent-get", arguments: arguments)
            .then(on: self.queue, self.make)
            .map { (wrapper: TorrentsWrapper) in wrapper.torrents }
    }
    
    public static func addTorrent(from source: Torrent.Source, location: String? = nil, maxPeers: Int? = nil, wanted: [Int], unwanted: [Int], start: Bool) -> Promise<Int> {
        guard let session = Service.shared.session else {
            return Promise(error: CocoaError.error("Session is nil"))
        }
        
        var arguments: [String : Any] = [
            "download-dir": location ?? session.downloadDir,
            "peer-limit": maxPeers ?? session.peerLimitPerTorrent,
            "paused": start ? 0 : 1,
            "files-wanted": wanted,
            "files-unwanted": unwanted
        ]
        
        switch source {
        case .file(let url):
            if let base64code = try? Data(contentsOf: url).base64EncodedString() {
                arguments["metainfo"] = base64code
            } else {
                return Promise(error: CocoaError.error("Error reading torrent file"))
            }
            break
        case .link(let magnet):
            arguments["filename"] = magnet
            break
        }
        
        return self.createRequest(method: "torrent-add", arguments: arguments)
            .then(on: self.queue, self.make)
            .map { (wrapper: TorrentAddedWrapper) in wrapper.torrentAdded.id }
    }
    
    public static func removeTorrents(by ids: [Int], deleteData: Bool = true) -> Promise<Void> {
        let arguments: [String: Any] = [
            "delete-local-data": deleteData ? 1 : 0,
            "ids": ids
        ]
        
        return self.createRequest(method: "torrent-remove", arguments: arguments)
            .then(on: self.queue, self.make)
            .map { (wrapper: Empty) in }
    }
    
    public static func set(wantedFiles: [Int], unwantedFiles: [Int], for torrents: [Int]) -> Promise<[Int]> {
        let arguments: [String: Any] = [
            "files-wanted": wantedFiles,
            "files-unwanted": unwantedFiles,
            "ids": torrents
        ]
        
        return self.createRequest(method: "torrent-set", arguments: arguments)
            .then(on: self.queue, self.make)
            .map { (wrapper: Empty) in torrents }
    }
    
    public static func startTorrents(by ids: [Int]) -> Promise<Void> {
        let arguments: [String: Any] = [
            "ids": ids
        ]
        
        return self.createRequest(method: "torrent-start", arguments: arguments)
            .then(on: self.queue, self.make)
            .map { (wrapper: Empty) in }
    }
    
    public static func stopTorrents(by ids: [Int]) -> Promise<Void> {
        let arguments: [String: Any] = [
            "ids": ids
        ]

        return self.createRequest(method: "torrent-stop", arguments: arguments)
            .then(on: self.queue, self.make)
            .map { (wrapper: Empty) in }
    }
    
    public static func set(location: String, for torrents: [Int], move: Bool) -> Promise<Void> {
        let arguments: [String: Any] = [
            "ids": torrents,
            "location": location,
            "move": move ? 1 : 0
        ]
        
        return self.createRequest(method: "torrent-set-location", arguments: arguments)
            .then(on: self.queue, self.make)
            .map { (wrapper: Empty) in }
    }
    
    public static func rename(path: String, to newPath: String, in torrent: Int) -> Promise<Void> {
        let arguments: [String: Any] = [
            "path": path,
            "name": newPath,
            "ids": [torrent]
        ]
        
        return self.createRequest(method: "torrent-rename-path", arguments: arguments)
            .then(on: self.queue, self.make)
            .map { (wrapper: Empty) in }
    }
    
    public static func set(priority: Int, for torrents: [Int]) -> Promise<Void> {
        let arguments: [String: Any] = [
            "bandwidthPriority": priority,
            "ids": torrents
        ]
        
        return self.createRequest(method: "torrent-set", arguments: arguments)
            .then(on: self.queue, self.make)
            .map { (wrapper: Empty) in }
    }
	
	// MARK: - Stuff for UI testing
	
	public static func setupStubs() {

		
		stub(condition: pathMatches("/transmission/rpc")) { request in
			guard let stream = request.httpBodyStream else { return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil) }
			
			stream.open()
			if let dict = try? JSONSerialization.jsonObject(with: stream, options: []) as? [String: Any] {
				if let method = dict["method"] as? String {
					if method == "session-get" {
						return self.testSessionResponse()
					} else if method == "torrent-get" {
						return self.testTorrentsResponse()
					}
				}
			}
			return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
		}
	}
	
	private static func testSessionResponse() -> OHHTTPStubsResponse {
		var server = Server()
		server.downloadDir = "/home/selim/downloads/torrent"
		server.freeSpace = 802673147904
		server.incompleteDir = "/dev/null/Downloads"
		server.incompleteDirEnabled = false
		server.peerLimitPerTorrent = 50
		server.version = "2.94 (test)"
		
		if let data = try? JSONEncoder().encode(server) {
			return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
		} else {
			return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
		}
	}
	
	private static func testTorrentsResponse() -> OHHTTPStubsResponse {
		var torrents: [Torrent] = []
		
		for i in 0..<500 {
			let torrent = Torrent(name: "Test torrent \(i)", files: [])
			torrents.append(torrent)
		}
		
		let torrentsWrapper = TorrentsWrapper(torrents:torrents)
		let response = Response<TorrentsWrapper>(arguments: torrentsWrapper)
		
		if let data = try? JSONEncoder().encode(response) {
			return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
		} else {
			return OHHTTPStubsResponse(data: Data(), statusCode: 404, headers: nil)
		}
	}
}
