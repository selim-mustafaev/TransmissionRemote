import Foundation

class Magnet {
    private(set) var link: String = ""
    private(set) var dn: String = ""
    private(set) var xt: String = ""
    private(set) var tr: String = ""
    
    init?(_ link: String) {
        self.link = link
        
        if !link.starts(with: "magnet:") {
            return nil
        }
        
        let params = link.dropFirst(8).split(separator: "&")
        for param in params {
            let keyVal = param.split(separator: "=")
            if keyVal.count != 2 {
                continue
            }
            
            let key = keyVal[0]
            let value = String(keyVal[1])
            
            switch key {
            case "dn":
                self.dn = value
                break
            case "xt":
                self.xt = value
                break
            case "tr":
                self.tr = value
                break
            default:
                break
            }
        }
        
    }
}
