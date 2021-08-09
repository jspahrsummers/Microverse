//
//  MacOSInstallView.swift
//  MacOSInstallView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI
import Virtualization

#if arch(arm64) && swift(>=5.5)

@available(macOS 12.0, *)
struct MacOSInstallView: View {
    var virtualMachineController: VirtualMachineController
    var restoreImageURL: URL
    @available(macOS 12.0, *)
    @State var installer: VZMacOSInstaller? = nil
    var action: () -> Void
    
    var body: some View {
        GroupBox(label: Text("macOS Installation")) {
            HStack {
                Form {
                    if let installer = installer {
                        ProgressView(installer.progress)
                    } else {
                        Button("Start") {
                            virtualMachineController.dispatchQueue.async {
                                let installer = VZMacOSInstaller(virtualMachine: virtualMachineController.virtualMachine, restoringFromImageAt: restoreImageURL)
                                
                                DispatchQueue.main.async {
                                    self.installer = installer
                                }
                                
                                NSLog("Starting installation into \(virtualMachineController) from \(restoreImageURL)")
                                installer.install { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success:
                                            action()
                                        case let .failure(error):
                                            NSLog("Failed to install macOS into VM: \(error)")
                                            self.installer = nil
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#endif
