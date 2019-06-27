import Foundation
import CoreSpotlight
import PromiseKit

extension CSSearchableIndex {
    
    func index(items: [CSSearchableItem]) -> Promise<Void> {
        return Promise { seal in
            self.indexSearchableItems(items) { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill_()
                }
            }
        }
    }
    
    func remove(ids: [String]) -> Promise<Void> {
        return Promise { seal in
            self.deleteSearchableItems(withIdentifiers: ids) { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill_()
                }
            }
        }
    }
    
}
