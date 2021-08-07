//
//  MacOSInstallView.swift
//  MacOSInstallView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI
import Virtualization

struct MacOSInstallView: View {
    var vzVirtualMachineConfiguration: VZVirtualMachineConfiguration
    var restoreImageURL: URL
    @State var installer: VZMacOSInstaller? = nil
    var action: () -> Void
    
    var body: some View {
        GroupBox("macOS Installation") {
            HStack {
                Form {
                    if let installer = installer {
                        ProgressView(installer.progress)
                    } else {
                        Button("Start") {
                            do {
                                try vzVirtualMachineConfiguration.validate()
                            } catch {
                                NSLog("Failed to validate machine configuration \(vzVirtualMachineConfiguration): \(error)")
                            }
                            
                            let vzVirtualMachine = VZVirtualMachine(configuration: vzVirtualMachineConfiguration)
                            installer = VZMacOSInstaller(virtualMachine: vzVirtualMachine, restoringFromImageAt: restoreImageURL)
                            NSLog("Starting installation into \(vzVirtualMachine) from \(restoreImageURL)")
                            installer!.install { result in
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
