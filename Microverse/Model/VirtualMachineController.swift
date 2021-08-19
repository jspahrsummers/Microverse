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
    
    let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    var guestOSServiceConnection: ClientConnection? = nil
    var guestOSServiceClient: Microverse_GuestOSServiceClient? = nil
    
    init(configuration: VZVirtualMachineConfiguration) throws {
        try configuration.validate()
        macAddresses = configuration.networkDevices.map { device in device.macAddress }
        virtualMachine = VZVirtualMachine(configuration: configuration, queue: dispatchQueue)
    }
    
    deinit {
        eventLoopGroup.shutdownGracefully { error in
            if let error = error {
                NSLog("Could not shut down MultiThreadedEventLoopGroup: \(error)")
            }
        }
        
        if let channel = guestOSServiceConnection {
            channel.close().whenComplete { result in
                if case let .failure(error) = result {
                    NSLog("Could not close GRPC channel: \(error)")
                }
            }
        }
    }
    
    private func connect() throws -> Microverse_GuestOSServiceClient {
        if let client = guestOSServiceClient {
            return client
        }
        
        guard let address = try lookUpAddresses().first else {
            throw MicroverseError.vmNotFoundOnNetwork
        }
        
        let channel = ClientConnection.insecure(group: eventLoopGroup)
            .connect(host: address, port: guestOSServicePortNumber)
        let client = Microverse_GuestOSServiceClient(channel: channel)
        guestOSServiceConnection = channel
        guestOSServiceClient = client
        return client
    }
    
    func pasteIntoVM(_ content: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            dispatchQueue.async {
                // TODO: Use virtio socket to connect to VM, and wrap GRPC around the file descriptor
                //            guard let socketDevice = virtualMachine.socketDevices.first as? VZVirtioSocketDevice else {
                //                cont.resume(with: .failure(MicroverseError.noSocketDevice))
                //                return
                //            }
                //
                //            socketDevice.connect(toPort: UInt32(guestOSServicePortNumber)) { result in
                //                guard case let .success(connection) = result else {
                //                    cont.resume(with: .failure(MicroverseError.guestOSServicesConnectionFailed))
                //                    return
                //                }
                //
                //                cont.resume(with: .success(()))
                //            }
                
                do {
                    let client = try self.connect()
                    let request = Microverse_PasteRequest.with {
                        $0.content = content
                    }
                    
                    let call = client.paste(request)
                    
                    call.response.whenSuccess { value in
                        NSLog("Paste succeeded: \(value)")
                    }
                    
                    call.response.whenFailure { error in
                        NSLog("Paste failed: \(error)")
                    }
                    
                    call.response.whenComplete { result in
                        NSLog("Paste result \(result): \(content)")
                        cont.resume(with: result.map { _ in () })
                    }
                    
                    NSLog("Started paste")
                    let value = try call.response.wait()
                    NSLog("Pasted: \(value)")
                } catch {
                    NSLog("Caught error when pasting: \(error)")
                    cont.resume(throwing: error)
                }
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
            guard let range = output.range(of: #"(?<=\()[^\)]+(?=\) at "# + rewriteMACAddress(macAddress.string) + #")"#, options: [.regularExpression, .caseInsensitive]) else {
                return nil
            }
            
            return String(output[range])
        }
    }
    
    private func rewriteMACAddress(_ macAddress: String) -> String {
        // Make the address format of VZMACAddress match `arp`
        return macAddress.split(separator: ":").map { component -> Substring in
            var c = component
            if c.starts(with: "0") {
                c.removeFirst()
            }
            
            return c
        }.joined(separator: ":")
    }
    
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        
    }
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        
    }
}
