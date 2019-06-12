//
//  BencodeKey.swift
//  Bencode
//
//  Created by Daniel Tombor on 2017. 09. 16..
//

import Foundation

/** For ordered encoding. */
public struct BencodeKey {
    
    public let key: String
    
    public let order: Int
    
    init(_ key: String, order: Int = Int.max) {
        self.key = key
        self.order = order
    }
}

extension BencodeKey: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    public static func ==(lhs: BencodeKey, rhs: BencodeKey) -> Bool {
        return lhs.key == rhs.key
    }
    
}

extension BencodeKey: Comparable {
    
    public static func <(lhs: BencodeKey, rhs: BencodeKey) -> Bool {
        if lhs.order != rhs.order {
            return lhs.order < rhs.order
        } else {
            return lhs.key < rhs.key
        }
    }
}

// MARK: - String helper extension

extension String {
    
    /** Convert string to BencodeKey */
    var bKey: BencodeKey {
        return BencodeKey(self)
    }
}
