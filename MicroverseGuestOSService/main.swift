//
//  main.swift
//  MicroverseGuestOSService
//
//  Created by Justin Spahr-Summers on 10/08/2021.
//

import Foundation
import MicroverseNetworking

do {
    let server = try Server(portNumber: guestOSServicePortNumber)
    server.run()
} catch {
    NSLog("Failed to start server: \(error)")
}
