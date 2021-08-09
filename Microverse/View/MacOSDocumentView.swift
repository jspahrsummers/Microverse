//
//  MacOSDocumentView.swift
//  MacOSDocumentView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI
import Virtualization

#if arch(arm64)

struct MacOSDocumentView: View {
    @Binding var virtualMachine: MacOSVirtualMachine
    @State var restoreImage: VZMacOSRestoreImage? = nil
    @State var virtualMachineController: VirtualMachineController? = nil
    @State var running = false
    
    var body: some View {
        if let virtualMachineController = virtualMachineController, running {
            VStack {
                VirtualMachineToolbar(virtualMachineController: virtualMachineController)
                VirtualMachineView(virtualMachine: virtualMachineController.virtualMachine)
            }
        } else {
            HStack {
                Spacer()
                VStack {
                    Spacer()
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
                    
                    AttachedDisksView(diskImages: $virtualMachine.attachedDiskImages)
                    
                    if virtualMachine.startupDiskURL != nil {
                        VirtualMachineConfigurationView(configuration: $virtualMachine.configuration)
                        
                        if virtualMachine.physicalMachine == nil {
                            MacRestoreImageView(restoreImage: $restoreImage)
                        }
                    }
                    
                    if let hardwareModel = restoreImage?.mostFeaturefulSupportedConfiguration?.hardwareModel ?? virtualMachine.physicalMachine?.hardwareModel {
                        MacAuxiliaryStorageView(hardwareModel: hardwareModel, auxiliaryStorageURL: $virtualMachine.auxiliaryStorageURL)
                    }
                    
                    if let virtualMachineController = virtualMachineController {
                        if !virtualMachine.osInstalled {
                            MacOSInstallView(virtualMachineController: virtualMachineController, restoreImageURL: restoreImage!.url) {
                                virtualMachine.osInstalled = true
                            }
                        } else {
                            Button("Start") {
                                virtualMachineController.dispatchQueue.async {
                                    virtualMachineController.virtualMachine.start { result in
                                        DispatchQueue.main.async {
                                            switch result {
                                            case .success:
                                                NSLog("Launched VM")
                                                running = true
                                            case let .failure(error):
                                                NSLog("Failed to start VM: \(error)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
                Spacer()
            }.onChange(of: restoreImage) { _ in
                guard let hardwareModel = restoreImage?.mostFeaturefulSupportedConfiguration?.hardwareModel else {
                    return
                }
                
                virtualMachine.physicalMachine = virtualMachine.physicalMachine ?? MacMachine(hardwareModelRepresentation: hardwareModel.dataRepresentation, machineIdentifierRepresentation: VZMacMachineIdentifier().dataRepresentation)
            }.task(id: virtualMachine) {
                do {
                    guard let vmConfig = try VZVirtualMachineConfiguration(forMacOSVM: virtualMachine) else {
                        DispatchQueue.main.async {
                            virtualMachineController = nil
                        }
                        
                        return
                    }
                    
                    let controller = try VirtualMachineController(configuration: vmConfig)
                    DispatchQueue.main.async {
                        virtualMachineController = controller
                    }
                } catch {
                    NSLog("Error preparing virtual machine controller: \(error)")
                }
            }
        }
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

#endif
