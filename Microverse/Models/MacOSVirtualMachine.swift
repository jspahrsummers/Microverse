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
    var attachedDiskImages: [AttachedDiskImage] = []
}

extension VZVirtualMachineConfiguration {
    convenience init?(forMacOSVM vm: MacOSVirtualMachine) throws {
        self.init(vm.configuration)
        
        guard let startupDiskURL = vm.startupDiskURL else {
            return nil
        }
        
        var storageDevices = try vm.attachedDiskImages.map { image in
            VZVirtioBlockDeviceConfiguration(attachment: try VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: image.path), readOnly: image.isReadOnly))
        }
        
        storageDevices.insert(VZVirtioBlockDeviceConfiguration(attachment: try VZDiskImageStorageDeviceAttachment(url: startupDiskURL, readOnly: false)), at: 0)
        self.storageDevices = storageDevices
        
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
        
//        let sharedDirectory = VZSharedDirectory(url: URL(fileURLWithPath: "/Applications"), readOnly: true)
//        let tag = "HostApplications"
//        try VZVirtioFileSystemDeviceConfiguration.validateTag(tag)
//
//        let fsDevice = VZVirtioFileSystemDeviceConfiguration(tag: tag)
//        fsDevice.share = VZSingleDirectoryShare(directory: sharedDirectory)
//        self.directorySharingDevices = [fsDevice]
    }
}
