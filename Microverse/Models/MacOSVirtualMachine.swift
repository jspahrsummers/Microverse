//
//  MacOSVirtualMachine.swift
//  MacOSVirtualMachine
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import Foundation
import Virtualization

struct MacMachine: Codable {
    var hardwareModelRepresentation: Data
    var hardwareModel: VZMacHardwareModel? {
        VZMacHardwareModel(dataRepresentation: hardwareModelRepresentation)
    }
    
    var machineIdentifierRepresentation: Data
    var machineIdentifier: VZMacMachineIdentifier? {
        VZMacMachineIdentifier(dataRepresentation: machineIdentifierRepresentation)
    }
}

struct MacOSVirtualMachine: Codable, ConfigurableVirtualMachine {
    var configuration: VirtualMachineConfiguration
    var startupDiskURL: URL? = nil
    var physicalMachine: MacMachine? = nil
}
