import Foundation
import DeepDiff

public class Tracker: Decodable, Mergeable {
	var host: String
	var announce: String
	var lastAnnounceSucceeded: Bool
	var lastAnnounceResult: String
	var lastAnnounceTime: Int64
	var nextAnnounceTime: Int64
	var seederCount: Int
	
	public var diffId: Int {
		return self.host.hashValue
	}
    
    public static func compareContent(_ a: Tracker, _ b: Tracker) -> Bool {
        return a.host == b.host
            && a.announce == b.announce
            && a.lastAnnounceTime == b.lastAnnounceTime
            && a.lastAnnounceSucceeded == b.lastAnnounceSucceeded
            && a.lastAnnounceResult == b.lastAnnounceResult
            && a.nextAnnounceTime == b.nextAnnounceTime
            && a.seederCount == b.seederCount
    }
	
	public func copy(from item: Tracker) {
		self.host = item.host
		self.announce = item.announce
		self.lastAnnounceSucceeded = item.lastAnnounceSucceeded
		self.lastAnnounceResult = item.lastAnnounceResult
		self.lastAnnounceTime = item.lastAnnounceTime
		self.nextAnnounceTime = item.nextAnnounceTime
		self.seederCount = item.seederCount
	}
}
