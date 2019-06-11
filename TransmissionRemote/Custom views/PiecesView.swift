import Cocoa
import BitArray

class PiecesView: NSView {

	var data: BitArray?
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
//		guard let data = data else { return }
		
//		let blocksPerPoint = CGFloat(data.count)/dirtyRect.width
//		for index in 0..<Int(dirtyRect.width) {
//			index*blocksPerPoint
//		}
    }
	
	func update(with bitArray: BitArray) {
		self.data = bitArray
		self.needsDisplay = true
	}
	
}
