//
//  MacOSDocumentView.swift
//  MacOSDocumentView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI
import Virtualization

struct MacOSDocumentView: View {
    @Binding var virtualMachine: MacOSVirtualMachine
    @State var restoreImage: VZMacOSRestoreImage? = nil
    @State var vzVirtualMachine: VZVirtualMachine? = nil
    
    var body: some View {
        VStack {
            GroupBox("Startup Disk") {
                if let startupDiskURL = virtualMachine.startupDiskURL {
                    Text("\(startupDiskURL.path)")
                } else {
                    DiskCreationView { url, bytes in
                        let blockSize: UInt64 = 4096
                        do {
                            let process = Process()
                            process.launchPath = "/bin/dd"
                            process.arguments = [
                                "if=/dev/zero",
                                "of=\(url.path)",
                                "bs=\(blockSize)",
                                "seek=\(bytes / blockSize)",
                                "count=0"
                            ]
                            try process.run()
                            process.waitUntilExit()
                            
                            virtualMachine.startupDiskURL = url
                        } catch {
                            NSLog("Failed to create disk image")
                        }
                    }
                }
            }
            
            if virtualMachine.startupDiskURL != nil {
                VirtualMachineConfigurationView(configuration: $virtualMachine.configuration)
                
                if virtualMachine.physicalMachine == nil {
                    MacRestoreImageView(restoreImage: $restoreImage)
                }
            }
            
            if let hardwareModel = restoreImage?.mostFeaturefulSupportedConfiguration?.hardwareModel ?? virtualMachine.physicalMachine?.hardwareModel {
                MacAuxiliaryStorageView(hardwareModel: hardwareModel, auxiliaryStorageURL: $virtualMachine.auxiliaryStorageURL)
            }
            
            if let vmConfig = try! VZVirtualMachineConfiguration(forMacOSVM: virtualMachine) {
                if !virtualMachine.osInstalled {
                    MacOSInstallView(vzVirtualMachineConfiguration: vmConfig, restoreImageURL: restoreImage!.url) {
                        virtualMachine.osInstalled = true
                    }
                } else if let vzVirtualMachine = vzVirtualMachine {
                    VirtualMachineView(virtualMachine: vzVirtualMachine)
                } else {
                    Button("Start") {
                        do {
                            try vmConfig.validate()
                            vzVirtualMachine = VZVirtualMachine(configuration: vmConfig)
                            vzVirtualMachine!.start { result in
                                switch result {
                                case .success:
                                    NSLog("Launched VM")
                                case let .failure(error):
                                    NSLog("Failed to start VM: \(error)")
                                    self.vzVirtualMachine = nil
                                }
                            }
                        } catch {
                            NSLog("Failed to validate machine configuration \(vmConfig): \(error)")
                        }
                    }
                }
            }
        }.onChange(of: restoreImage, perform: { _ in
            if let hardwareModel = restoreImage?.mostFeaturefulSupportedConfiguration?.hardwareModel, virtualMachine.physicalMachine == nil {
                virtualMachine.physicalMachine = MacMachine(hardwareModelRepresentation: hardwareModel.dataRepresentation, machineIdentifierRepresentation: VZMacMachineIdentifier().dataRepresentation)
            }
        })
    }
}

struct MacOSDocumentView_Previews: PreviewProvider {
    struct Holder: View {
        @State var virtualMachine = MacOSVirtualMachine(configuration: VirtualMachineConfiguration())
        var body: some View {
            MacOSDocumentView(virtualMachine: $virtualMachine)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
