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
    var auxiliaryStorageURL: URL? = nil
    var physicalMachine: MacMachine? = nil
    var osInstalled = false
}

extension VZVirtualMachineConfiguration {
    convenience init?(forMacOSVM vm: MacOSVirtualMachine) throws {
        self.init(vm.configuration)
        
        guard let startupDiskURL = vm.startupDiskURL else {
            return nil
        }
        
        self.storageDevices = [VZVirtioBlockDeviceConfiguration(attachment: try VZDiskImageStorageDeviceAttachment(url: startupDiskURL, readOnly: false))]
        
        guard let hardwareModel = vm.physicalMachine?.hardwareModel, let machineIdentifier = vm.physicalMachine?.machineIdentifier, let auxiliaryStorageURL = vm.auxiliaryStorageURL else {
            return nil
        }
        
        let platform = VZMacPlatformConfiguration()
        platform.hardwareModel = hardwareModel
        platform.machineIdentifier = machineIdentifier
        platform.auxiliaryStorage = VZMacAuxiliaryStorage(contentsOf: auxiliaryStorageURL)
        self.platform = platform
        
        let graphics = VZMacGraphicsDeviceConfiguration()
        graphics.displays = [
            VZMacGraphicsDisplayConfiguration(
                widthInPixels: 2560,
                heightInPixels: 1600,
                pixelsPerInch: 220
            )
        ]
        self.graphicsDevices = [graphics]
        
        self.bootLoader = VZMacOSBootLoader()
    }
}
