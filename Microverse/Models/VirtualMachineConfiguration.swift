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
    
    public var CPUCount = min(max(2, minimumCPUCount), maximumCPUCount)
    public var memoryMB = min(max(4096, minimumMemoryMB), maximumMemoryMB)
}

extension VZVirtualMachineConfiguration {
    convenience init(_ config: VirtualMachineConfiguration) {
        self.init()
        self.cpuCount = config.CPUCount
        self.memorySize = config.memoryMB * 1024 * 1024
        self.memoryBalloonDevices = [VZVirtioTraditionalMemoryBalloonDeviceConfiguration()]
        self.entropyDevices = [VZVirtioEntropyDeviceConfiguration()]
        
        let network = VZVirtioNetworkDeviceConfiguration()
        network.attachment = VZNATNetworkDeviceAttachment()
        self.networkDevices = [network]
    }
}
