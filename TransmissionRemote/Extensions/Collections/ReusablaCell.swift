import Foundation

public protocol ReusableCell {
	static var reuseIdentifier: String { get }
}

public extension ReusableCell {
	static var reuseIdentifier: String {
		return String(describing: self)
	}
}

