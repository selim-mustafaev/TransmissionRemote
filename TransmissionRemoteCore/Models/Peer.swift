import Foundation
import DifferenceKit

public class Peer: Codable, Mergeable {
	public var address: String
	public var port: Int
	public var clientName: String
	public var flagStr: String
	public var progress: Float
	public var rateToClient: Int64
	public var rateToPeer: Int64
	
	public var differenceIdentifier: Int {
		return "\(self.address):\(self.port)".hashValue
	}
    
    public static func compareContent(_ a: Peer, _ b: Peer) -> Bool {
        return a.address == b.address
            && a.clientName == b.clientName
            && a.progress == b.progress
            && a.rateToPeer == b.rateToPeer
            && a.rateToClient == b.rateToClient
            && a.flagStr == b.flagStr
    }
	
	public func isContentEqual(to source: Peer) -> Bool {
        return self.address == source.address
            && self.clientName == source.clientName
            && self.progress == source.progress
            && self.rateToPeer == source.rateToPeer
            && self.rateToClient == source.rateToClient
            && self.flagStr == source.flagStr
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
