//
//  MacOSInstallView.swift
//  MacOSInstallView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI

struct MacOSInstallView: View {
    @Binding var virtualMachine: MacOSVirtualMachine
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MacOSInstallView_Previews: PreviewProvider {
    struct Holder: View {
        @State var virtualMachine = MacOSVirtualMachine(configuration: VirtualMachineConfiguration())
        var body: some View {
            return MacOSInstallView(virtualMachine: $virtualMachine)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
