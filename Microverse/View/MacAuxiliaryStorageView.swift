//
//  MacAuxiliaryStorageView.swift
//  MacAuxiliaryStorageView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers
import Virtualization

#if arch(arm64) && swift(>=5.5)

@available(macOS 12.0, *)
struct MacAuxiliaryStorageView: View {
    var hardwareModel: VZMacHardwareModel
    @Binding var auxiliaryStorageURL: URL?
    
    var body: some View {
        GroupBox("macOS Auxiliary Storage") {
            HStack {
                Form {
                    if let url = auxiliaryStorageURL {
                        Text(url.path)
                        Button("Reset") {
                            auxiliaryStorageURL = nil
                        }
                    } else {
                        Button("Create…") {
                            let panel = NSSavePanel()
                            panel.allowedContentTypes = [UTType.diskImage]
                            panel.nameFieldStringValue = "aux.img"
                            panel.allowsOtherFileTypes = true
                            panel.canCreateDirectories = true
                            panel.begin { response in
                                guard response == NSApplication.ModalResponse.OK, let url = panel.url else {
                                    return
                                }
                                
                                do {
                                    let auxStorage = try VZMacAuxiliaryStorage(creatingStorageAt: url, hardwareModel: hardwareModel, options: .allowOverwrite)
                                    self.auxiliaryStorageURL = auxStorage.url
                                } catch {
                                    NSLog("Failed to create auxiliary storage at \(url): \(error)")
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
