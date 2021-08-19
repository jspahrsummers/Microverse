//
//  main.swift
//  MicroverseGuestOSService
//
//  Created by Justin Spahr-Summers on 10/08/2021.
//

import AppKit
import Foundation

final class Server: NSObject, PortDelegate {
    let port: SocketPort
    
    required init(portNumber: Int) throws {
        guard let port = SocketPort(tcpPort: UInt16(portNumber)) else {
            throw MicroverseError.guestOSServiceFailedToStart
        }
        
        self.port = port
        super.init()
        
        port.setDelegate(self)
        port.schedule(in: RunLoop.current, forMode: .common)
    }
    
    deinit {
        port.invalidate()
    }
    
    func run() {
        RunLoop.current.run()
    }
    
    func handle(_ message: PortMessage) {
        do {
            let decoded = try MicroverseMessage.init(fromPortMessage: message)
            
            switch decoded {
            case let .paste(content):
                NSLog("Paste: \(content)")
                NSPasteboard.general.setString(content, forType: .string)
            }
        } catch {
            NSLog("Error decoding port message: \(error)")
        }
    }
}

do {
    let server = try Server(portNumber: guestOSServicePortNumber)
    server.run()
} catch {
    NSLog("Failed to start server: \(error)")
}
