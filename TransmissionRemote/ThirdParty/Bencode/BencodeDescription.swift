//
//  BencodePrintExtension.swift
//  bencoder_macos
//
//  Created by Daniel Tombor on 2017. 09. 13..
//

import Foundation

extension Bencode: CustomDebugStringConvertible {
    
    /** Pretty-ish debug print */
    public var debugDescription: String {
        return desc(tabsCount: 0)
    }
    
    // Print helper
    private func desc(tabsCount count: Int) -> String {
        
        let tabs = Array<String>(repeating: "\t", count: count).joined()
        
        switch self {
        case .integer(let i): return "\(tabs)\(i)"
        case .string(let data): return tabs + (data.string ?? "Can't parse to string")
        case .list(let l):
            let desc = l.map { $0.desc(tabsCount: count+1) }.joined(separator: ",\n")
            return "\(tabs)[\n\(desc)\n\(tabs)]"
        case .dictionary(let d):
            let desc = d.map {
                let key = "\(tabs)\t\($0.key) : "
                let value = $1.desc(tabsCount: count+1)
                let begin = value.index(value.startIndex, offsetBy: (count+1))
                return key + String(value.suffix(from: begin))
            }.joined(separator:",\n")
            return "\(tabs){\n\(desc)\n\(tabs)}"
        }
    }
}
