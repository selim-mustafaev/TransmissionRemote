//
//  Sequence+Async.swift
//  TransmissionRemoteCore
//
//  Created by Selim Mustafaev on 09.05.2023.
//  Copyright © 2023 selim mustafaev. All rights reserved.
//

import Foundation

extension Sequence {
    
    func asyncMap<T>(_ operation: @escaping (Element) async throws -> T) async rethrows -> [T] {
        
        try await withThrowingTaskGroup(of: T.self) { group in
            for element in self {
                group.addTask {
                    try await operation(element)
                }
            }
            
            var elements: [T] = []
            for try await elem in group {
                elements.append(elem)
            }
            
            return elements
        }
    }
}
