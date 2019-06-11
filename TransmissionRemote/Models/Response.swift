import Foundation

struct Response<T>: Decodable where T: Decodable {
    var arguments: T
    var result: String
}
