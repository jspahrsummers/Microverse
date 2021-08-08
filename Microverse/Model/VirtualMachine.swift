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
    
    var linuxVM: LinuxVirtualMachine? {
        switch self {
        case let .linux(vm):
            return vm
        default:
            return nil
        }
    }
    
    var macOSVM: MacOSVirtualMachine? {
        switch self {
        case let .macOS(vm):
            return vm
        default:
            return nil
        }
    }
    
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