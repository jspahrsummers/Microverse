//
//  VirtualMachine.swift
//  VirtualMachine
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import Foundation

enum VirtualMachine: Codable, ConfigurableVirtualMachine {
    case linux(LinuxVirtualMachine)
    case macOS(MacOSVirtualMachine)
    
    var configuration: VirtualMachineConfiguration {
        get {
            switch self {
            case let .linux(vm):
                return vm.configuration
            case let .macOS(vm):
                return vm.configuration
            }
        }
        set(value) {
            switch self {
            case var .linux(vm):
                vm.configuration = value
            case var .macOS(vm):
                vm.configuration = value
            }
        }
    }
}

protocol ConfigurableVirtualMachine {
    var configuration: VirtualMachineConfiguration { get set }
}

struct LinuxVirtualMachine: Codable, ConfigurableVirtualMachine {
    var configuration: VirtualMachineConfiguration
}

struct MacOSVirtualMachine: Codable, ConfigurableVirtualMachine {
    var configuration: VirtualMachineConfiguration
}
