//
//  Extensions.swift
//  Bencode
//
//  Created by Daniel Tombor on 2017. 09. 28..
//

import Foundation

// MARK: - [UInt8] Extension

internal typealias Byte = UInt8

internal extension Sequence where Iterator.Element == Byte {
    
    var int: Int? {
        guard let string = String(bytes: self, encoding: .ascii)
            else { return nil }
        return Int(string)
    }
    
    var string: String? {
        return String(bytes: self, encoding: .ascii)
    }
}

// MARK: - String extension

internal extension String {
    
    var ascii: [Byte] {
        return unicodeScalars.map { return Byte($0.value) }
    }
}
