//
//  VirtualMachine.swift
//  VirtualMachine
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import Foundation

enum VirtualMachine: Codable, ConfigurableVirtualMachine {
    
    private enum CodingKeys: String, CodingKey {
        case linux
    }
    
    enum CodingError: Error {
        case unsupported(String)
    }
    
    init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        if value.contains(.linux) {
            let linux = try value.decode(LinuxVirtualMachine.self, forKey: .linux)
            self = .linux(linux)
        } else {
            throw CodingError.unsupported("unsupported vm for platform")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var key = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .linux(let vm):
            try key.encode(vm, forKey: .linux)
        }
    }
    
    case linux(LinuxVirtualMachine)
    
    var linuxVM: LinuxVirtualMachine? {
        switch self {
        case let .linux(vm):
            return vm
        default:
            return nil
        }
    }
    
    #if arch(arm64) && swift(>=5.5)
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
            
            #if arch(arm64) && swift(>=5.5)
            case let .macOS(vm):
                return vm.configuration
            #endif
            }
        }
        set(value) {
            switch self {
            case var .linux(vm):
                vm.configuration = value
                
            #if arch(arm64) && swift(>=5.5)
            case var .macOS(vm):
                vm.configuration = value
            #endif
            }
        }
    }
}
