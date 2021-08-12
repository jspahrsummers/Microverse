//
//  VirtualMachineController.swift
//  VirtualMachineController
//
//  Created by Justin Spahr-Summers on 08/08/2021.
//

import Foundation
import GRPC
import NIO
import Virtualization

final class VirtualMachineController: NSObject, VZVirtualMachineDelegate {
    let dispatchQueue = DispatchQueue(label: "com.metacognitive.Microverse.VirtualMachineController", qos: .userInitiated, attributes: .init(), autoreleaseFrequency: .workItem)
    let virtualMachine: VZVirtualMachine
    
    init(configuration: VZVirtualMachineConfiguration) throws {
        try configuration.validate()
        virtualMachine = VZVirtualMachine(configuration: configuration, queue: dispatchQueue)
    }
    
    func pasteIntoVM(_ content: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            guard let socketDevice = virtualMachine.socketDevices.first as? VZVirtioSocketDevice else {
                cont.resume(with: .failure(MicroverseError.noSocketDevice))
                return
            }
            
            socketDevice.connect(toPort: UInt32(guestOSServicePortNumber)) { result in
                guard case let .success(connection) = result else {
                    cont.resume(with: .failure(MicroverseError.guestOSServicesConnectionFailed))
                    return
                }
                
//                let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
//                
//                // Make sure the group is shutdown when we're done with it.
//                defer {
//                    try! group.syncShutdownGracefully()
//                }
//                
//                // Configure the channel, we're not using TLS so the connection is `insecure`.
//                let channel = ClientConnection.insecure(group: group)
//                    .connect(host: port:)
//                
//                // Close the connection when we're done with it.
//                defer {
//                    try! channel.close().wait()
//                }
//                
//                // Provide the connection to the generated client.
//                let greeter = Helloworld_GreeterClient(channel: channel)
//                
//                // Do the greeting.
//                greet(name: self.name, client: greeter)
                
                cont.resume(with: .success(()))
            }
        }
    }
    
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        
    }
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        
    }
}
