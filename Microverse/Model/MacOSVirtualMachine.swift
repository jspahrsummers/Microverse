//
//  MacOSVirtualMachine.swift
//  MacOSVirtualMachine
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import Foundation
import Virtualization

#if arch(arm64)

struct MacMachine: Codable, Equatable, Hashable {
    var hardwareModelRepresentation: Data
    var hardwareModel: VZMacHardwareModel? {
        VZMacHardwareModel(dataRepresentation: hardwareModelRepresentation)
    }
    
    var machineIdentifierRepresentation: Data
    var machineIdentifier: VZMacMachineIdentifier? {
        VZMacMachineIdentifier(dataRepresentation: machineIdentifierRepresentation)
    }
}

struct MacOSVirtualMachine: ConfigurableVirtualMachine, Equatable {
    var configuration: VirtualMachineConfiguration
    var startupDiskURL: URL? = nil
    var auxiliaryStorageURL: URL? = nil
    
    var physicalMachine: MacMachine? = nil
    var osInstalled = false
    var attachedDiskImages: [AttachedDiskImage] = []
}

extension MacOSVirtualMachine: Codable {
    enum CodingKeys: CodingKey {
        case configuration
        case startupDiskBookmark
        case auxiliaryStorageBookmark
        case physicalMachine
        case osInstalled
        case attachedDiskImageBookmarks
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(configuration, forKey: .configuration)
        try container.encodeIfPresent(bookmarkForURL: startupDiskURL, options: .withSecurityScope, forKey: .startupDiskBookmark)
        try container.encodeIfPresent(bookmarkForURL: auxiliaryStorageURL, options: .withSecurityScope, forKey: .auxiliaryStorageBookmark)
        try container.encodeIfPresent(physicalMachine, forKey: .physicalMachine)
        try container.encode(osInstalled, forKey: .osInstalled)
        try container.encode(attachedDiskImages, forKey: .attachedDiskImageBookmarks)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        configuration = try values.decode(VirtualMachineConfiguration.self, forKey: .configuration)
        
        var stale = false
        
        startupDiskURL = try values.decodeURLFromBookmarkIfPresent(options: .withSecurityScope, forKey: .startupDiskBookmark, stale: &stale)
        if let startupDiskURL = startupDiskURL {
            // FIXME: This is imbalanced right now!
            guard startupDiskURL.startAccessingSecurityScopedResource() else {
                throw CocoaError(.fileReadNoPermission)
            }
        }
        
        auxiliaryStorageURL = try values.decodeURLFromBookmarkIfPresent(options: .withSecurityScope, forKey: .auxiliaryStorageBookmark, stale: &stale)
        if let auxiliaryStorageURL = auxiliaryStorageURL {
            // FIXME: This is imbalanced right now!
            guard auxiliaryStorageURL.startAccessingSecurityScopedResource() else {
                throw CocoaError(.fileReadNoPermission)
            }
        }
        
        physicalMachine = try values.decodeIfPresent(MacMachine.self, forKey: .physicalMachine)
        osInstalled = try values.decode(Bool.self, forKey: .osInstalled)
        attachedDiskImages = try values.decode([AttachedDiskImage].self, forKey: .attachedDiskImageBookmarks)
    }
}

extension VZVirtualMachineConfiguration {
    convenience init?(forMacOSVM vm: MacOSVirtualMachine) throws {
        self.init(vm.configuration)
        
        guard let startupDiskURL = vm.startupDiskURL else {
            return nil
        }
        
        var storageDevices = try vm.attachedDiskImages.filter { image in
            !image.path.isEmpty
        }.map { image in
            VZVirtioBlockDeviceConfiguration(attachment: try VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: image.path), readOnly: image.isReadOnly, cachingMode: .automatic, synchronizationMode: VZDiskImageSynchronizationMode(image.synchronizationMode)))
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
    }
}

#endif
