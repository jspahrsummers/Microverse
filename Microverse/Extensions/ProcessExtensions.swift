//
//  ProcessExtensions.swift
//  ProcessExtensions
//
//  Created by Justin Spahr-Summers on 10/08/2021.
//

import Foundation

extension Process {
    func start() async throws {
        withCheckedThrowingContinuation {
            terminationHandler
            
            try self.run()
        }
    }
}
