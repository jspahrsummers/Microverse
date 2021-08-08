//
//  LinuxDocumentView.swift
//  LinuxDocumentView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI
import Virtualization

struct LinuxDocumentView: View {
    @Binding var virtualMachine: LinuxVirtualMachine
    @State var linuxBoot = LinuxBootViewModel()
    @State var attachedDisks: [AttachedDiskImage] = []
    @State var virtualMachineController: VirtualMachineController? = nil
    @State var running = false
    
    var body: some View {
        if let virtualMachineController = virtualMachineController, running {
            VirtualMachineView(virtualMachine: virtualMachineController.virtualMachine)
        } else {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    VirtualMachineConfigurationView(configuration: $virtualMachine.configuration)
                    LinuxBootView(viewModel: $linuxBoot)
                    AttachedDisksView(diskImages: $attachedDisks)
                    Button("Launch") {
                        let storageDevices = attachedDisks.map { image in
                            VZVirtioBlockDeviceConfiguration(attachment: try! VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: image.path), readOnly: image.isReadOnly))
                        }
                        
                        let config = VZVirtualMachineConfiguration(virtualMachine.configuration)
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
                        
                        virtualMachineController = try! VirtualMachineController(configuration: config)
                        
                        virtualMachineController!.dispatchQueue.async {
                            virtualMachineController?.virtualMachine.start { result in
                                NSLog("Machine started: \(result)")
                            }
                        }
                        
                        let consoleView = ConsoleView(fileHandleToReadFrom: pipeForReadingFromVM.fileHandleForReading, fileHandleToWriteTo: pipeForWritingToVM.fileHandleForWriting)
                        let window = NSWindow(rootView: consoleView)
                        Task {
                            window.title = "Terminal"
                            window.setContentSize(NSSize(width: 800, height: 600))
                            window.makeKeyAndOrderFront(nil)
                        }
                    }
                    Spacer()
                }
                Spacer()
            }
        }
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
