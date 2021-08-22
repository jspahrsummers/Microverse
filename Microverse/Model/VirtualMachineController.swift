//
//  VirtualMachineController.swift
//  VirtualMachineController
//
//  Created by Justin Spahr-Summers on 08/08/2021.
//

import Foundation
import MicroverseNetworking
import Virtualization

final class VirtualMachineController: NSObject, VZVirtualMachineDelegate {
    let dispatchQueue = DispatchQueue(label: "com.metacognitive.Microverse.VirtualMachineController", qos: .userInitiated, attributes: .init(), autoreleaseFrequency: .workItem)
    let virtualMachine: VZVirtualMachine
    let macAddresses: [VZMACAddress]
    
    var socketClient: Client? = nil
    
    init(configuration: VZVirtualMachineConfiguration) throws {
        try configuration.validate()
        macAddresses = configuration.networkDevices.map { device in device.macAddress }
        virtualMachine = VZVirtualMachine(configuration: configuration, queue: dispatchQueue)
    }
    
    private func connect() async throws -> Client {
        if let socketClient = socketClient {
            return socketClient
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
                        do {
                            let client = try Client(fileDescriptor: connection.fileDescriptor)
                            self.socketClient = client
                            return .success(client)
                        } catch {
                            return .failure(error)
                        }
                    })
                }
            }
        }
    }
    
    func pasteIntoVM(_ content: String) async throws {
        let client = try await connect()
        try await client.send(.paste(content: content))
    }
    
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        
    }
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        
    }
}
