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
                    document.virtualMachine = .macOS(MacOSVirtualMachine(configuration: config))
                    
                case .linux:
                    document.virtualMachine = .linux(LinuxVirtualMachine(configuration: config))
                }
            }
            
        case .some(.linux):
            LinuxDocumentView(virtualMachine: Binding(get: {
                return document.virtualMachine!.linuxVM!
            }, set: { vm in document.virtualMachine = .linux(vm) }))
            
        case .some(.macOS):
            MacOSDocumentView(virtualMachine: Binding(get: {
                return document.virtualMachine!.macOSVM!
            }, set: { vm in document.virtualMachine = .macOS(vm) }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(document: Binding.constant(MicroverseDocument()))
    }
}
