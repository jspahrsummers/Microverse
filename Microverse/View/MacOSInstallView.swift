//
//  MacOSInstallView.swift
//  MacOSInstallView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import Combine
import SwiftUI
import Virtualization

#if arch(arm64)

struct MacOSInstallView: View {
    var virtualMachineController: VirtualMachineController
    var restoreImageURL: URL
    @State var installer: VZMacOSInstaller? = nil
    @State var progress = 0.0
    var action: () -> Void
    
    var body: some View {
        GroupBox("macOS Installation") {
            HStack {
                Form {
                    if installer != nil {
                        ProgressView(value: progress) {
                            Text("Installing…")
                        } currentValueLabel: {
                            Text("\(Int(progress * 100))% completed")
                        }
                    } else {
                        Button("Start") {
                            virtualMachineController.dispatchQueue.async {
                                let installer = VZMacOSInstaller(virtualMachine: virtualMachineController.virtualMachine, restoringFromImageAt: restoreImageURL)

                                DispatchQueue.main.async {
                                    self.installer = installer
                                    self.progress = 0.0
                                }
                                
                                let cancellable = installer.progress.publisher(for: \.completedUnitCount)
                                    .map { completed in Double(completed) / Double(installer.progress.totalUnitCount) }
                                    .receive(on: DispatchQueue.main)
                                    .sink { progress in
                                        self.progress = progress
                                    }

                                NSLog("Starting installation into \(virtualMachineController) from \(restoreImageURL)")
                                installer.install { [cancellable] result in
                                    cancellable.cancel()
                                    
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
