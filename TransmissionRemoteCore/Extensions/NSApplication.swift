import Foundation

extension NSApplication {
	public static var underUITest: Bool {
		ProcessInfo.processInfo.environment.contains(where: { $0.key == "isUITest" && $0.value == "true" })
	}
}
