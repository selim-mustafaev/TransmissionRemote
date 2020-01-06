import Foundation
import DeepDiff

public class Tracker: Codable, Mergeable {
	public var host: String
	public var announce: String
	public var lastAnnounceSucceeded: Bool
	public var lastAnnounceResult: String
	public var lastAnnounceTime: Int64
	public var nextAnnounceTime: Int64
	public var seederCount: Int
	
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
