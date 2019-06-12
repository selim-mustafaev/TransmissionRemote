import Foundation

public extension CocoaError {
    
    static func error(_ description: String) -> Error {
        return error(Code(rawValue: 0), userInfo: [NSLocalizedDescriptionKey: description], url: nil)
    }
    
    static func error(_ description: String, suggestion: String) -> Error {
        let info = [
            NSLocalizedDescriptionKey: description,
            NSLocalizedRecoverySuggestionErrorKey: suggestion
        ]
        return error(Code(rawValue: 0), userInfo: info, url: nil)
    }
    
    static func cancelError(_ userInfo: [String: Any]? = nil) -> Error {
        return error(Code.userCancelled, userInfo: userInfo, url: nil)
    }
}
