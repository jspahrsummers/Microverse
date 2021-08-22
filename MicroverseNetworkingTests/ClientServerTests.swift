//
//  MicroverseNetworkingTests.swift
//  MicroverseNetworkingTests
//
//  Created by Justin Spahr-Summers on 22/08/2021.
//

import MicroverseNetworking
import XCTest

class ClientServerTests: XCTestCase {
    func testClientConnectsToServer() async throws {
        let port: UInt32 = 12345
        let server = try Server(portNumber: port)
        server.run()
        
        let client = try Client(connectingToPort: port)
        try await client.send(.paste(content: "foobar"))
    }
}
