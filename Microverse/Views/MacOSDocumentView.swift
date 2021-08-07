//
//  MacOSDocumentView.swift
//  MacOSDocumentView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI

struct MacOSDocumentView: View {
    @Binding var virtualMachine: MacOSVirtualMachine
    
    var body: some View {
        VirtualMachineConfigurationView(configuration: $virtualMachine.configuration)
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
