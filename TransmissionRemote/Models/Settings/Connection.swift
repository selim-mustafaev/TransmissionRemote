import Foundation

struct Connection: Codable {
    private(set) var host: String = ""
    private(set) var port: Int = 9091
    private(set) var rpcPath: String = "/transmission/rpc"
    private(set) var useSSL: Bool = false
    
    init() {
        
    }
    
    init(host: String, port: Int, rpcPath: String) {
        self.host = host
        self.port = port
        self.rpcPath = rpcPath
    }
    
    func protectionSpace() -> URLProtectionSpace {
        let proto =  self.useSSL ? NSURLProtectionSpaceHTTPS : NSURLProtectionSpaceHTTP
        return URLProtectionSpace(host: self.host, port: self.port, protocol: proto, realm: "Transmission", authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
    }
    
    func isComplete() -> Bool {
        return self.host.count > 0
    }
    
    func url() -> URL? {
        let proto =  self.useSSL ? "https" : "http"
        return URL(string: "\(proto)://\(self.host):\(self.port)\(self.rpcPath)")
    }
	
	func removeCredentials() {
        let allCreds = URLCredentialStorage.shared.allCredentials
        print("all credentials: \(allCreds.count)")
		for (space, credDict) in URLCredentialStorage.shared.allCredentials.filter({ $0.0.realm == "Transmission" }) {
			for (_, cred) in credDict {
                print("Removing for space: \(space)")
				URLCredentialStorage.shared.remove(cred, for: space)
			}
		}
	}
	
	func saveCredentials(username: String, password: String) {
		let credential = URLCredential(user: username, password: password, persistence: .permanent)
		URLCredentialStorage.shared.setDefaultCredential(credential, for: self.protectionSpace())
	}
}
