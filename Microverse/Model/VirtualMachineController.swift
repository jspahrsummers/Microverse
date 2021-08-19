//
//  VirtualMachineController.swift
//  VirtualMachineController
//
//  Created by Justin Spahr-Summers on 08/08/2021.
//

import Foundation
import Virtualization

final class VirtualMachineController: NSObject, VZVirtualMachineDelegate {
    let dispatchQueue = DispatchQueue(label: "com.metacognitive.Microverse.VirtualMachineController", qos: .userInitiated, attributes: .init(), autoreleaseFrequency: .workItem)
    let virtualMachine: VZVirtualMachine
    let macAddresses: [VZMACAddress]
    
    var sendPort: SocketPort? = nil
    
    init(configuration: VZVirtualMachineConfiguration) throws {
        try configuration.validate()
        macAddresses = configuration.networkDevices.map { device in device.macAddress }
        virtualMachine = VZVirtualMachine(configuration: configuration, queue: dispatchQueue)
    }
    
    deinit {
        sendPort?.invalidate()
    }
    
    private func connect() async throws -> SocketPort {
        if let sendPort = sendPort {
            return sendPort
        }
        
        return try await withCheckedThrowingContinuation { cont in
            dispatchQueue.async {
                guard let socketDevice = self.virtualMachine.socketDevices.first as? VZVirtioSocketDevice else {
                    cont.resume(with: .failure(MicroverseError.noSocketDevice))
                    return
                }

                socketDevice.connect(toPort: UInt32(guestOSServicePortNumber)) { result in
                    NSLog("Connection result (to VM over socket device): \(result)")
                    cont.resume(with: result.flatMap { connection in
                        guard let sendPort = SocketPort(protocolFamily: AF_VSOCK, socketType: SOCK_STREAM, protocol: 0, socket: connection.fileDescriptor) else {
                            return .failure(MicroverseError.guestOSServicesConnectionFailed)
                        }
                        
                        self.sendPort = sendPort
                        return .success(sendPort)
                    })
                }
            }
        }
    }
    
    func pasteIntoVM(_ content: String) async throws {
        let sendPort = try await connect()
        let message = try PortMessage(send: sendPort, receive: nil, microverseMessage: .paste(content: content))
        try await message.send(before: Date.init(timeIntervalSinceNow: 1), qos: .userInitiated)
    }
//
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        
    }
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        
    }
}
