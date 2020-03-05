import Foundation
import DifferenceKit

public class Tracker: Codable, Mergeable {
	public var host: String
	public var announce: String
	public var lastAnnounceSucceeded: Bool
	public var lastAnnounceResult: String
	public var lastAnnounceTime: Int64
	public var nextAnnounceTime: Int64
	public var seederCount: Int
	
	public var differenceIdentifier: Int {
		return self.host.hashValue
	}
	
	public func isContentEqual(to source: Tracker) -> Bool {
        return self.host == source.host
            && self.announce == source.announce
            && self.lastAnnounceTime == source.lastAnnounceTime
            && self.lastAnnounceSucceeded == source.lastAnnounceSucceeded
            && self.lastAnnounceResult == source.lastAnnounceResult
            && self.nextAnnounceTime == source.nextAnnounceTime
            && self.seederCount == source.seederCount
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
