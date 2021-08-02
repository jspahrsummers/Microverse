//
//  ContentView.swift
//  Microverse
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: MicroverseDocument
    @State var configuration = VirtualMachineConfiguration()

    var body: some View {
        VirtualMachineConfigurationView(configuration: $configuration)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(MicroverseDocument()))
    }
}
