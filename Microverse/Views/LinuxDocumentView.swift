//
//  LinuxDocumentView.swift
//  LinuxDocumentView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI

struct LinuxDocumentView: View {
    @Binding var virtualMachine: LinuxVirtualMachine
    
    var body: some View {
        VirtualMachineConfigurationView(configuration: $virtualMachine.configuration)
    }
}

struct LinuxDocumentView_Previews: PreviewProvider {
    struct Holder: View {
        @State var virtualMachine = LinuxVirtualMachine(configuration: VirtualMachineConfiguration())
        var body: some View {
            LinuxDocumentView(virtualMachine: $virtualMachine)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
