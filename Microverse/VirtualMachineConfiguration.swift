//
//  VirtualMachineConfiguration.swift
//  VirtualMachineConfiguration
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import Foundation
import Virtualization

struct VirtualMachineConfiguration: Codable {
    static let minimumCPUCount = VZVirtualMachineConfiguration.minimumAllowedCPUCount
    static let maximumCPUCount = VZVirtualMachineConfiguration.maximumAllowedCPUCount
    static let minimumMemoryMB = max(VZVirtualMachineConfiguration.minimumAllowedMemorySize / 1024 / 1024, 256)
    static let maximumMemoryMB = VZVirtualMachineConfiguration.maximumAllowedMemorySize / 1024 / 1024
    
    public var CPUCount = minimumCPUCount
    public var memoryMB = minimumMemoryMB
}

extension VZVirtualMachineConfiguration {
    convenience init(_ config: VirtualMachineConfiguration) {
        self.init()
        self.cpuCount = config.CPUCount
        self.memorySize = config.memoryMB * 1024 * 1024
        self.memoryBalloonDevices = [VZVirtioTraditionalMemoryBalloonDeviceConfiguration()]
        self.entropyDevices = [VZVirtioEntropyDeviceConfiguration()]
        
        let serialOut = VZVirtioConsoleDeviceSerialPortConfiguration()
        serialOut.attachment = VZFileHandleSerialPortAttachment(fileHandleForReading: nil, fileHandleForWriting: FileHandle.standardError)
        self.serialPorts = [serialOut]
        
        let network = VZVirtioNetworkDeviceConfiguration()
        network.attachment = VZNATNetworkDeviceAttachment()
        self.networkDevices = [network]
    }
}
