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
    
    init(configuration: VZVirtualMachineConfiguration) throws {
        try configuration.validate()
        macAddresses = configuration.networkDevices.map { device in device.macAddress }
        virtualMachine = VZVirtualMachine(configuration: configuration, queue: dispatchQueue)
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
