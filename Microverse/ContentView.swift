//
//  ContentView.swift
//  Microverse
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import Virtualization

struct ContentView: View {
    @Binding var document: MicroverseDocument
    @State var linuxBoot = LinuxBootViewModel()
    @State var configuration = VirtualMachineConfiguration()
    @State var machine: VZVirtualMachine?

    var body: some View {
        if let machine = machine {
            VirtualMachineView(virtualMachine: machine)
        } else {
            VStack {
                VirtualMachineConfigurationView(configuration: $configuration)
                LinuxBootView(viewModel: $linuxBoot)
                Button("Launch") {
                    let config = VZVirtualMachineConfiguration(configuration)
                    
                    let bootLoader = VZLinuxBootLoader(kernelURL: URL(fileURLWithPath: linuxBoot.kernelPath))
                    bootLoader.commandLine = linuxBoot.commandLine
                    bootLoader.initialRamdiskURL = URL(fileURLWithPath: linuxBoot.initialRamdiskPath)
                    config.bootLoader = bootLoader
                    
                    machine = VZVirtualMachine(configuration: config)
                    machine?.start(completionHandler: { _ in })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(MicroverseDocument()))
    }
}
