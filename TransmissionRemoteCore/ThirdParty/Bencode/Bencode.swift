//
//  Decoder.swift
//  Bencoder
//
//  Created by Daniel Tombor on 2017. 09. 12..
//

import Foundation

// MARK: - Bencode

public enum Bencode {
    case integer(Int)
    case string([UInt8])
    indirect case list([Bencode])
    indirect case dictionary([BencodeKey:Bencode])
}

public extension Bencode {
    
    /** Decoding from Bencoded string */
    init?(bencodedString str: String) {
        guard let bencode = try? Bencoder().decode(bencodedString: str)
            else { return nil }
        self = bencode
    }
    
    /** Decoding bencoded file */
    init?(file url: URL) {
        guard let bencode = try? Bencoder().decode(file: url)
            else { return nil }
        self = bencode
    }
    
    /** Decoding from bytes */
    init?(bytes: [UInt8]) {
        guard let bencode = try? Bencoder().decode(bytes: bytes)
            else { return nil }
        self = bencode
    }
    
    /** Encoding to Bencode string */
    var encoded: String {
        return Bencoder().encoded(bencode: self)
    }
    
    /** Encoding to Bencoded Data */
    var asciiEncoding: Data {
        return Bencoder().asciiEncoding(bencode: self)
    }
}
