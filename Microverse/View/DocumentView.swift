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
        #if arch(arm64)
        case .macOS:
            MacOSDocumentView(virtualMachine: Binding(get: {
                return document.virtualMachine.macOSVM!
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
