//
//  Client.swift
//  Client
//
//  Created by Justin Spahr-Summers on 22/08/2021.
//

import Foundation

public final class Client {
    let sendPort: SocketPort
    
    public init(connectingToPort port: UInt32) throws {
        var addr = sockaddr_vm()
        addr.svm_len = UInt8(MemoryLayout.size(ofValue: addr))
        addr.svm_family = sa_family_t(AF_VSOCK)
        addr.svm_port = UInt32(port)
        addr.svm_cid = VMADDR_CID_ANY
        
        let addrData = withUnsafeBytes(of: &addr) { Data($0) }
        
        guard let sendPort = SocketPort(protocolFamily: AF_VSOCK, socketType: SOCK_STREAM, protocol: 0, address: addrData) else {
            throw NetworkingError.couldNotCreatePort
        }
        
        self.sendPort = sendPort
    }
    
    public init(fileDescriptor: SocketNativeHandle) throws {
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
