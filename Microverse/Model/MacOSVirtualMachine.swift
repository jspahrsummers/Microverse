//
//  MacOSVirtualMachine.swift
//  MacOSVirtualMachine
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import Foundation
import Virtualization

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

struct MacOSVirtualMachine: Codable, ConfigurableVirtualMachine, Equatable {
    var configuration: VirtualMachineConfiguration
    
    var startupDiskBookmark: Data? = nil
    var startupDiskURL: URL? {
        get {
            guard let startupDiskBookmark = startupDiskBookmark else {
                return nil
            }

            do {
                var stale = false
                let url = try URL(resolvingBookmarkData: startupDiskBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &stale)
                
                // FIXME: This is imbalanced right now!
                if !url.startAccessingSecurityScopedResource() {
                    throw CocoaError(.fileReadNoPermission)
                }
                
                return url
            } catch {
                NSLog("Could not resolve startup disk bookmark: \(error)")
                return nil
            }
        }
        set(url) {
            do {
                startupDiskBookmark = try url?.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            } catch {
                NSLog("Could not create startup disk bookmark: \(error)")
            }
        }
    }
    
    var auxiliaryStorageBookmark: Data? = nil
    var auxiliaryStorageURL: URL? {
        get {
            guard let auxiliaryStorageBookmark = auxiliaryStorageBookmark else {
                return nil
            }
            
            do {
                var stale = false
                let url = try URL(resolvingBookmarkData: auxiliaryStorageBookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &stale)
                
                // FIXME: This is imbalanced right now!
                if !url.startAccessingSecurityScopedResource() {
                    throw CocoaError(.fileReadNoPermission)
                }
                
                return url
            } catch {
                NSLog("Could not resolve auxiliary storage bookmark: \(error)")
                return nil
            }
        }
        set(url) {
            do {
                auxiliaryStorageBookmark = try url?.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            } catch {
                NSLog("Could not create auxiliary storage bookmark: \(error)")
            }
        }
    }
    
    var physicalMachine: MacMachine? = nil
    var osInstalled = false
    
    // TODO: These should be saved as security-scoped bookmarks
    var attachedDiskImages: [AttachedDiskImage] = []
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
