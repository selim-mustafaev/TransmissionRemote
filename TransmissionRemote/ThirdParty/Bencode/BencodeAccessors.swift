//
//  BencodeSubscriptExtension.swift
//  bencoder_macos
//
//  Created by Daniel Tombor on 2017. 09. 13..
//

import Foundation

public enum BencodeOptional {
    case none
    case bencode(Bencode)
}

public extension Bencode {
    
    /** Accessing int value */
    var int: Int? {
        guard case .integer(let i) = self else { return nil }
        return i
    }
    
    /** Accessing string value */
    var string: String? {
        guard case .string(let bytes) = self else { return nil }
        return bytes.string
    }
    
    /** Accessing list */
    var list: [Bencode]? {
        guard case .list(let l) = self else { return nil }
        return l
    }
    
    /** Accessing dictionary */
    var dict: [BencodeKey: Bencode]? {
        guard case .dictionary(let d) = self else { return nil }
        return d
    }
    
    /** Accessing bytes */
    var bytes: [UInt8]? {
        guard case .string(let bytes) = self else { return nil }
        return bytes
    }
    
    /** returns all items if bencode is a list or dictionary
     none if its a string or integer */
    var values: [Bencode] {
        return self.map { $0.value }
    }
    
    /** Accessing list item by index */
    subscript(index: Int) -> BencodeOptional {
        guard case .list(let l) = self,
            index >= 0, index < l.count else { return .none }
        return .bencode(l[index])
    }
    
    /** Accessing dictionary value by key */
    subscript(key: String) -> BencodeOptional {
        guard case .dictionary(let d) = self,
            let b = d[key.bKey] else { return .none }
        return .bencode(b)
    }
}

public extension BencodeOptional {
    
    /** Accessing bencode enum */
    var bencode: Bencode? {
        guard case .bencode(let b) = self else { return nil }
        return b
    }
    
    /** Accessing encoded string */
    var encoded: String? {
        return bencode?.encoded
    }
    
    /** Accessing encoded data */
    var asciiEncoding: Data? {
        return bencode?.asciiEncoding
    }
    
    /** Accessing int value */
    var int: Int? {
        return bencode?.int
    }
    
    /** Accessing string value */
    var string: String? {
        return bencode?.string
    }
    
    /** Accessing list */
    var list: [Bencode]? {
        return bencode?.list
    }
    
    /** Accessing dictionary */
    var dict: [BencodeKey: Bencode]? {
        return bencode?.dict
    }
    
    /** Accessing bytes */
    var bytes: [UInt8]? {
        return bencode?.bytes
    }
    
    /** Returns all items if bencode is a list or dictionary
     none if its a string or integer */
    var values: [Bencode] {
        return self.map { $0.value }
    }
    
    /** Accessing list item by index */
    subscript(index: Int) -> BencodeOptional {
        guard case .bencode(let b) = self else { return .none }
        return b[index]
    }
    
    /** Accessing dictionary value by key */
    subscript(key: String) -> BencodeOptional {
        guard case .bencode(let b) = self else { return .none }
        return b[key]
    }
}

