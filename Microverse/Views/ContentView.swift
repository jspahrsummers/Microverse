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
    @State var attachedDisks = AttachedDisksViewModel()
    @State var configuration = VirtualMachineConfiguration()
    @State var machine: VZVirtualMachine?
    @State var restoreImage: VZMacOSRestoreImage? = nil
    
    let pipeForReadingFromVM = Pipe()
    let pipeForWritingToVM = Pipe()

    var body: some View {
        MacRestoreView(restoreImage: $restoreImage)
        
        if let machine = machine {
            VirtualMachineView(virtualMachine: machine)
        } else {
            VStack {
                VirtualMachineConfigurationView(configuration: $configuration)
                LinuxBootView(viewModel: $linuxBoot)
                AttachedDisksView(viewModel: $attachedDisks)
                Button("Launch") {
                    let storageDevices = attachedDisks.diskImages.map { image in
                        VZVirtioBlockDeviceConfiguration(attachment: try! VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: image.path), readOnly: image.isReadOnly))
                    }
                    
                    let config = VZVirtualMachineConfiguration(configuration)
                    config.storageDevices = storageDevices
                    
                    let pipeForReadingFromVM = Pipe()
                    let pipeForWritingToVM = Pipe()
                    
                    let serialOut = VZVirtioConsoleDeviceSerialPortConfiguration()
                    serialOut.attachment = VZFileHandleSerialPortAttachment(fileHandleForReading: pipeForWritingToVM.fileHandleForReading, fileHandleForWriting: pipeForReadingFromVM.fileHandleForWriting)
                    config.serialPorts = [serialOut]
                    
                    let bootLoader = VZLinuxBootLoader(kernelURL: URL(fileURLWithPath: linuxBoot.kernelPath))
                    bootLoader.commandLine = linuxBoot.commandLine
                    bootLoader.initialRamdiskURL = URL(fileURLWithPath: linuxBoot.initialRamdiskPath)
                    config.bootLoader = bootLoader
                    
                    try! config.validate()
                    
                    machine = VZVirtualMachine(configuration: config)
                    machine?.start(completionHandler: { result in NSLog("Machine started: \(result)") })
                    
                    let consoleView = ConsoleView(fileHandleToReadFrom: pipeForReadingFromVM.fileHandleForReading, fileHandleToWriteTo: pipeForWritingToVM.fileHandleForWriting)
                    let window = NSWindow(rootView: consoleView)
                    Task {
                        window.title = "Terminal"
                        window.setContentSize(NSSize(width: 800, height: 600))
                        window.makeKeyAndOrderFront(nil)
                    }
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
