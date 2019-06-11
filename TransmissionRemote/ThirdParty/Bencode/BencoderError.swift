//
//  BencoderError.swift
//  Bencode
//
//  Created by Daniel Tombor on 2018. 04. 30..
//

import Foundation

enum BencoderError: Error {
    case unknownToken(UInt8)
    case tokenNotFound(UInt8)
    case unexpectedKey(Bencode)
    case invalidNumber
    case indexOutOfBounds(end: Int, current: Int)
}
