import Foundation
import Cocoa

public class ConfigurableCell<T>: NSTableCellView, ReusableCell {
	func configure(with item: T, at column: NSUserInterfaceItemIdentifier) { }
}
