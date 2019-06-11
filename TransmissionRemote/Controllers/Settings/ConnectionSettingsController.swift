import Cocoa

class ConnectionSettingsController: NSViewController {
    
    @IBOutlet weak var hostField: NSTextField!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var rpcPathField: NSTextField!
    @IBOutlet weak var useSslButton: NSButton!
    @IBOutlet weak var authRequiredButton: NSButton!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    @IBOutlet weak var askPasswordButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let conn = Settings.shared.connection
        self.hostField.stringValue = conn.host
        self.portField.stringValue = String(conn.port)
        self.rpcPathField.stringValue = conn.rpcPath
        self.useSslButton.state = conn.useSSL ? .on : .off
        self.authRequiredButton.state = Settings.shared.authRequired ? .on : .off
        
        if let (_, credDict) = URLCredentialStorage.shared.allCredentials.first(where: { $0.0.realm == "Transmission" }) {
            if let credential = credDict.first?.value {
                self.usernameField.stringValue = credential.user ?? ""
                self.passwordField.stringValue = credential.password ?? ""
            }
        }
        
        self.usernameField.isEnabled = Settings.shared.authRequired
        self.passwordField.isEnabled = Settings.shared.authRequired
    }
    
    // MARK: - Actions
    
    @IBAction func authRequiredChanged(_ sender: NSButton) {
        Settings.shared.authRequired = sender.state == .on
        self.usernameField.isEnabled = Settings.shared.authRequired
        self.passwordField.isEnabled = Settings.shared.authRequired
        
        if !Settings.shared.authRequired {
            Settings.shared.connection.removeCredentials()
        }
        
        NotificationCenter.default.post(name: .connectionSettingsUpdated, object: nil, userInfo: nil)
    }
    
    @IBAction func hostChanged(_ sender: NSTextField) {
        guard sender.stringValue != Settings.shared.connection.host else { return }
        
        let old = Settings.shared.connection
        Settings.shared.connection = Connection(host: sender.stringValue, port: old.port, rpcPath: old.rpcPath)
        
        if Settings.shared.authRequired {
            old.removeCredentials()
        }
        
        self.handleConnectionSettingsChanged()
    }
    
    @IBAction func portChanged(_ sender: NSTextField) {
        guard sender.integerValue != Settings.shared.connection.port else { return }
        
        let old = Settings.shared.connection
        Settings.shared.connection = Connection(host: old.host, port: sender.integerValue, rpcPath: old.rpcPath)

        if Settings.shared.authRequired {
            old.removeCredentials()
        }
        
        self.handleConnectionSettingsChanged()
    }
    
    @IBAction func rpcPathChanged(_ sender: NSTextField) {
        guard sender.stringValue != Settings.shared.connection.rpcPath else { return }
        
        let old = Settings.shared.connection
        Settings.shared.connection = Connection(host: old.host, port: old.port, rpcPath: sender.stringValue)
        
        if Settings.shared.authRequired {
            old.removeCredentials()
        }
        
        self.handleConnectionSettingsChanged()
    }
	
	@IBAction func usernameChanged(_ sender: NSTextField) {
		self.handleConnectionSettingsChanged()
	}
	
	@IBAction func passwordChanged(_ sender: NSTextField) {
		self.handleConnectionSettingsChanged()
	}
    
    // MARK: - Utils
    
    func handleConnectionSettingsChanged() {
        if self.connectionSettingsAreValid() {
            if Settings.shared.authRequired {
                Settings.shared.connection.saveCredentials(username: self.usernameField.stringValue, password: self.passwordField.stringValue)
            }
            NotificationCenter.default.post(name: .connectionSettingsUpdated, object: nil, userInfo: nil)
        }
    }
    
    // Stubs for validation
    
    func hostIsValid() -> Bool {
        return self.hostField.stringValue.count > 0
    }
    
    func portIsValid() -> Bool {
        return self.portField.stringValue.count > 0
    }
    
    func rpcPathIsValid() -> Bool {
        return self.rpcPathField.stringValue.count > 0
    }
    
    func usernameIsValid() -> Bool {
        return self.usernameField.stringValue.count > 0
    }
    
    func passwordIsValid() -> Bool {
        return self.passwordField.stringValue.count > 3
    }
    
    func connectionSettingsAreValid() -> Bool {
        let basicParamsValid = self.hostIsValid() && self.portIsValid() && self.rpcPathIsValid()
        if Settings.shared.authRequired {
            return basicParamsValid && self.usernameIsValid() && self.passwordIsValid()
        } else {
            return basicParamsValid
        }
    }
}
