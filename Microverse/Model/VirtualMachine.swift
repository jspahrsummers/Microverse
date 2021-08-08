//
//  VirtualMachine.swift
//  VirtualMachine
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import Foundation

enum VirtualMachine: Codable, ConfigurableVirtualMachine {
    case linux(LinuxVirtualMachine)
    
    var linuxVM: LinuxVirtualMachine? {
        switch self {
        case let .linux(vm):
            return vm
        default:
            return nil
        }
    }
    
    #if arch(arm64)
    case macOS(MacOSVirtualMachine)
    
    var macOSVM: MacOSVirtualMachine? {
        switch self {
        case let .macOS(vm):
            return vm
        default:
            return nil
        }
    }
    #endif
    
    var configuration: VirtualMachineConfiguration {
        get {
            switch self {
            case let .linux(vm):
                return vm.configuration
            
            #if arch(arm64)
            case let .macOS(vm):
                return vm.configuration
            #endif
            }
        }
        set(value) {
            switch self {
            case var .linux(vm):
                vm.configuration = value
                
            #if arch(arm64)
            case var .macOS(vm):
                vm.configuration = value
            #endif
            }
        }
    }
}
