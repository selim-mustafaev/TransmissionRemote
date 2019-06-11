//
//  Bencoder.swift
//  Bencode
//
//  Created by Daniel Tombor on 2018. 04. 30..
//

import Foundation

final class Bencoder {

    // MARK: - Constants

    private struct Tokens {
        let i: UInt8 = 0x69
        let l: UInt8 = 0x6c
        let d: UInt8 = 0x64
        let e: UInt8 = 0x65
        let zero: UInt8 = 0x30
        let nine: UInt8 = 0x39
        let colon: UInt8 = 0x3a
    }

    private let tokens = Tokens()

    // MARK: - Methods

    /** Decoding from Bencoded string */
    func decode(bencodedString str: String) throws -> Bencode {
        return try decode(bytes: str.ascii)
    }

    /** Decoding bencoded file */
    func decode(file url: URL) throws -> Bencode {
        let data = try Data(contentsOf: url)
        return try decode(bytes: [Byte](data))
    }

    /** Decoding from bytes */
    func decode(bytes: [UInt8]) throws -> Bencode {
        return try parse(bytes).bencode
    }

    /** Encoding to Bencode string */
    func encoded(bencode: Bencode) -> String {
        switch bencode {
        case .integer(let i): return "i\(i)e"
        case .string(let b): return "\(b.count):\(String(bytes: b, encoding: .ascii)!)"
        case .list(let l):
            let desc = l.map { $0.encoded }.joined()
            return "l\(desc)e"
        case .dictionary(let d):
            let desc = d.sorted(by: { $0.key < $1.key })
                .map { "\(Bencode.string($0.key.ascii).encoded)\($1.encoded)" }
                .joined()
            return "d\(desc)e"
        }
    }

    /** Encoding to Bencoded Data */
    func asciiEncoding(bencode: Bencode) -> Data {
        return Data(encoded(bencode: bencode).ascii)
    }
}

// MARK: - Private decoding helpers

private extension Bencoder {

    typealias ParseResult = (bencode: Bencode, index: Int)

    func parse(_ data: [Byte]) throws -> ParseResult {
        return try parse(ArraySlice(data), from: 0)
    }

    func parse(_ data: ArraySlice<Byte>, from index: Int) throws -> ParseResult {
        guard data.endIndex >= index + 1
            else { throw BencoderError.indexOutOfBounds(end: data.endIndex, current: index + 1) }

        let nextIndex = index+1
        let nextSlice = data[nextIndex...]

        switch data[index] {
        case tokens.i: return try parseInt(nextSlice, from: nextIndex)
        case tokens.zero...tokens.nine: return try parseString(data, from: index)
        case tokens.l: return try parseList(nextSlice, from: nextIndex)
        case tokens.d: return try parseDictionary(nextSlice, from: nextIndex)
        default: throw BencoderError.unknownToken(data[index])
        }
    }

    func parseInt(_ data: ArraySlice<Byte>, from index: Int) throws -> ParseResult {
        guard let end = data.firstIndex(of: tokens.e)
            else { throw BencoderError.tokenNotFound(tokens.e) }
        guard let num = Array(data[..<end]).int
            else { throw BencoderError.invalidNumber }
        return (bencode: .integer(num), index: end+1)
    }

    func parseString(_ data: ArraySlice<Byte>, from index: Int) throws -> ParseResult {
        guard let sep = data.firstIndex(of: tokens.colon)
            else { throw BencoderError.tokenNotFound(tokens.colon) }
        guard let len = Array(data[..<sep]).int
            else { throw BencoderError.invalidNumber }
        let start = sep + 1
        let end = data.index(start, offsetBy: len)
        return (bencode: .string(Array(data[start..<end])), index: end)
    }

    func parseList(_ data: ArraySlice<Byte>, from index: Int) throws -> ParseResult {
        var l: [Bencode] = []
        var idx: Int = index

        while data[idx] != tokens.e {
            let result = try parse(data[idx...], from: idx)
            l.append(result.bencode)
            idx = result.index
        }
        return (bencode: .list(l), index: idx+1)
    }

    func parseDictionary(_ data: ArraySlice<Byte>, from index: Int) throws -> ParseResult {
        var d: [BencodeKey:Bencode] = [:]
        var idx: Int = index
        var order = 0

        while data[idx] != tokens.e {
            let keyResult = try parseString(data[idx...], from: idx)
            guard case .string(let keyData) = keyResult.bencode,
                let key = keyData.string
                else { throw BencoderError.unexpectedKey(keyResult.bencode) }
            let valueResult = try parse(data[keyResult.index...], from: keyResult.index)
            d[BencodeKey(key, order: order)] = valueResult.bencode
            idx = valueResult.index
            order += 1
        }
        return (bencode: .dictionary(d), index: idx+1)
    }
}
