import Foundation

struct Response<T>: Codable where T: Codable {
    var arguments: T
    var result: String
	
	init(arguments: T) {
		self.arguments = arguments
		self.result = "success"
	}
}
