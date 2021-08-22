//
//  main.swift
//  MicroverseGuestOSService
//
//  Created by Justin Spahr-Summers on 10/08/2021.
//

import AppKit
import Foundation
import MicroverseNetworking
import System

final class Server: NSObject, PortDelegate {
    let fd: Int32
    
    required init(portNumber: Int) throws {
        self.fd = socket(AF_VSOCK, SOCK_STREAM, 0)
        
        super.init()
        
        var addr = sockaddr_vm()
        addr.svm_len = UInt8(MemoryLayout.size(ofValue: addr))
        addr.svm_family = sa_family_t(AF_VSOCK)
        addr.svm_port = UInt32(portNumber)
        addr.svm_cid = VMADDR_CID_ANY
        try withUnsafePointer(to: addr) { ptr in
            try ptr.withMemoryRebound(to: sockaddr.self, capacity: Int(addr.svm_len)) { ptr in
                guard Darwin.bind(self.fd, ptr, socklen_t(addr.svm_len)) == 0 else {
                    throw Errno(rawValue: errno)
                }
            }
        }
        
        guard listen(self.fd, 5) == 0 else {
            throw Errno(rawValue: errno)
        }
        
//        port.setDelegate(self)
//        port.schedule(in: RunLoop.current, forMode: .common)
    }
    
    deinit {
//        port.invalidate()
    }
    
    func run() {
        Task {
            var addr = sockaddr()
            var len: socklen_t = 0
            while true {
                let acceptedFd = accept(self.fd, &addr, &len)
                guard acceptedFd >= 0 else {
                    throw Errno(rawValue: errno)
                }
                
                guard let port = SocketPort(protocolFamily: AF_VSOCK, socketType: SOCK_STREAM, protocol: 0, socket: acceptedFd) else {
                    // TODO: Better error message
                    throw MicroverseError.guestOSServicesConnectionFailed
                }
                
                port.setDelegate(self)
                port.schedule(in: RunLoop.current, forMode: .common)
                
                // TODO: Invalidate ports
            }
        }
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
