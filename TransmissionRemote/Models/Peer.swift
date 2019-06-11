import Foundation
import DeepDiff

class Peer: Decodable, Mergeable {
	var address: String
	var port: Int
	var clientName: String
	var flagStr: String
	var progress: Float
	var rateToClient: Int64
	var rateToPeer: Int64
	
	public var diffId: Int {
		return "\(self.address):\(self.port)".hashValue
	}
    
    static func compareContent(_ a: Peer, _ b: Peer) -> Bool {
        return a.address == b.address
            && a.clientName == b.clientName
            && a.progress == b.progress
            && a.rateToPeer == b.rateToPeer
            && a.rateToClient == b.rateToClient
            && a.flagStr == b.flagStr
    }
	
	public func copy(from item: Peer) {
		self.address = item.address
		self.port = item.port
		self.clientName = item.clientName
		self.flagStr = item.flagStr
		self.progress = item.progress
		self.rateToClient = item.rateToClient
		self.rateToPeer = item.rateToPeer
	}
}
