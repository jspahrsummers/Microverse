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
    
    func pasteIntoVM(_ content: String, username: String, password: String) throws {
        let addresses = try lookUpAddresses()
        guard let address = addresses.first else {
            throw MicroverseError.vmNotFoundOnNetwork
            
        }
        
        guard let data = content.data(using: .utf8) else {
            throw MicroverseError.invalidData
        }
        
        try withAskPassInTemporaryFile(password: password) { askPassURL in
            let pipe = Pipe()
            
            var environment = ProcessInfo.processInfo.environment
            environment["SSH_ASKPASS_REQUIRE"] = "force"
            environment["SSH_ASKPASS"] = askPassURL.path
            
            let process = Process()
            process.launchPath = "/usr/bin/ssh"
            process.arguments = ["-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "-l", username, address, "pbcopy"]
            process.standardInput = pipe
            try process.run()
            
            try pipe.fileHandleForWriting.write(contentsOf: data)
            pipe.fileHandleForWriting.closeFile()
            
            // TODO: Make this async
            process.waitUntilExit()
        }
    }
    
    func copyFromVM(username: String, password: String) throws -> String {
        let addresses = try lookUpAddresses()
        guard let address = addresses.first else {
            throw MicroverseError.vmNotFoundOnNetwork
        }
        
        return ""
    }
    
    private func createTemporaryFileURL() throws -> URL {
        return try FileManager().url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
    }
    
    // FIXME: This isn't a secure way to provide a password, it's just a temporary hack
    private func withAskPassInTemporaryFile<T>(password: String, closure: (URL) throws -> T) throws -> T {
        var fileURL = try createTemporaryFileURL()
        
        let script = """
#/bin/bash
echo '\(password)'
"""
        
        try script.write(to: fileURL, atomically: true, encoding: .utf8)
        
        do {
            let attributes: [FileAttributeKey: Any] = [ .posixPermissions: 0o755 ]
            try FileManager().setAttributes(attributes, ofItemAtPath: fileURL.path)
            
            // oh hi there i hate everything
            let process = Process()
            process.launchPath = "/usr/bin/xattr"
            process.arguments = ["-d", "com.apple.quarantine", fileURL.path]
            try process.run()
            
            // TODO: Make this async
            process.waitUntilExit()
            
            let result = try closure(fileURL)
            
            try FileManager().removeItem(at: fileURL)
            return result
        } catch {
            try FileManager().removeItem(at: fileURL)
            throw error
        }
        
    }
    
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        
    }
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        
    }
}
