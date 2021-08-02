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
