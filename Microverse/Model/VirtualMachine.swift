//
//  VirtualMachine.swift
//  VirtualMachine
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import Foundation

enum VirtualMachine: Codable, ConfigurableVirtualMachine {
    #if arch(arm64)
    case macOS(MacOSVirtualMachine)
    
    var macOSVM: MacOSVirtualMachine? {
        switch self {
        case let .macOS(vm):
            return vm
        }
    }
    #endif
    
    var configuration: VirtualMachineConfiguration {
        get {
            switch self {
            #if arch(arm64)
            case let .macOS(vm):
                return vm.configuration
            #endif
            }
        }
        set(value) {
            switch self {
            #if arch(arm64)
            case var .macOS(vm):
                vm.configuration = value
            #endif
            }
        }
    }
}
