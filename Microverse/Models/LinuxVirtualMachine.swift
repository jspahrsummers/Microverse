//
//  LinuxVirtualMachine.swift
//  LinuxVirtualMachine
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import Foundation

struct LinuxVirtualMachine: Codable, ConfigurableVirtualMachine {
    var configuration: VirtualMachineConfiguration
}
