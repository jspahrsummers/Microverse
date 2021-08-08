//
//  ContentView.swift
//  Microverse
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import Virtualization

struct DocumentView: View {
    @Binding var document: MicroverseDocument
    
    var body: some View {
        switch document.virtualMachine {
        case .none:
            BlankDocumentView { platform in
                let config = VirtualMachineConfiguration()
                
                switch platform {
                case .macOS:
                    #if arch(arm64) && swift(>=5.5)
                    document.virtualMachine = .macOS(MacOSVirtualMachine(configuration: config))
                    #else
                    let alert = NSAlert()
                    alert.messageText = "Unsupported platform"
                    alert.informativeText = "Running macOS as a guest VM requires an arm64 machine."
                    alert.runModal()
                    #endif
                    
                case .linux:
                    document.virtualMachine = .linux(LinuxVirtualMachine(configuration: config))
                }
            }
            
        case .some(.linux):
            LinuxDocumentView(virtualMachine: Binding(get: {
                return document.virtualMachine!.linuxVM!
            }, set: { vm in document.virtualMachine = .linux(vm) }))
        
        #if arch(arm64) && swift(>=5.5)
        case .some(.macOS):
            MacOSDocumentView(virtualMachine: Binding(get: {
                return document.virtualMachine!.macOSVM!
            }, set: { vm in document.virtualMachine = .macOS(vm) }))
        #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(document: Binding.constant(MicroverseDocument()))
    }
}
