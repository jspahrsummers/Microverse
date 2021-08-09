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
    let macAddresses: [VZMACAddress]
    
    init(configuration: VZVirtualMachineConfiguration) throws {
        try configuration.validate()
        macAddresses = configuration.networkDevices.map { device in device.macAddress }
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

    func lookUpAddresses() throws -> [String] {
        let pipe = Pipe()
        
        let process = Process()
        process.launchPath = "/usr/sbin/arp"
        process.arguments = ["-an"]
        process.standardOutput = pipe
        try process.run()
        
        // TODO: Make this async
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            throw MicroverseError.stringEncodingError
        }
        
        return macAddresses.compactMap { macAddress in
            guard let range = output.range(of: #"(?<=\()[^\)]+(?=\) at "# + macAddress.string + #")"#, options: [.regularExpression, .caseInsensitive]) else {
                return nil
            }
            
            return String(output[range])
        }
    }
    
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        
    }
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        
    }
}
