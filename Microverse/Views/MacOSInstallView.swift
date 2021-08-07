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
    var action: (Result<Void, Error>) -> Void
    
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
                            let installer = VZMacOSInstaller(virtualMachine: vzVirtualMachine, restoringFromImageAt: restoreImageURL)
                            self.installer = installer
                            installer.install(completionHandler: action)
                        }
                    }
                }
            }
        }
    }
}
