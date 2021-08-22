//
//  Client.swift
//  Client
//
//  Created by Justin Spahr-Summers on 22/08/2021.
//

import Foundation

public final class Client {
    let sendPort: SocketPort
    
    public required init(fileDescriptor: SocketNativeHandle) throws {
        guard let sendPort = SocketPort(protocolFamily: AF_VSOCK, socketType: SOCK_STREAM, protocol: 0, socket: fileDescriptor) else {
            throw NetworkingError.couldNotCreatePort
        }
        
        self.sendPort = sendPort
    }
    
    deinit {
        sendPort.invalidate()
    }
    
    public func send(_ message: MicroverseMessage) async throws {
        let portMessage = try PortMessage(send: sendPort, receive: nil, microverseMessage: message)
        try await portMessage.send(before: Date.init(timeIntervalSinceNow: 1), qos: .userInitiated)
    }
}
