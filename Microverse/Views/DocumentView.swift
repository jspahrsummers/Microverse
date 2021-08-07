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
        Spacer()
        HStack {
            Spacer()
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
                
            case let .some(.linux(vm)):
                LinuxDocumentView()
                
            case let .some(.macOS(vm)):
                MacOSDocumentView()
            }
            Spacer()
        }
        Spacer()
    }
}

//struct DocumentView: View {
//    @Binding var document: MicroverseDocument
//    @State var linuxBoot = LinuxBootViewModel()
//    @State var attachedDisks = AttachedDisksViewModel()
//    @State var configuration = VirtualMachineConfiguration()
//    @State var machine: VZVirtualMachine?
//    @State var restoreImage: VZMacOSRestoreImage? = nil
//
//    let pipeForReadingFromVM = Pipe()
//    let pipeForWritingToVM = Pipe()
//
//    var body: some View {
//        if let machine = machine {
//            VirtualMachineView(virtualMachine: machine)
//        } else {
//            Spacer()
//            HStack {
//                Spacer()
//                VStack {
//                    MacRestoreView(restoreImage: $restoreImage)
//                    VirtualMachineConfigurationView(configuration: $configuration)
//                    LinuxBootView(viewModel: $linuxBoot)
//                    AttachedDisksView(viewModel: $attachedDisks)
//                    Button("Launch") {
//                        let storageDevices = attachedDisks.diskImages.map { image in
//                            VZVirtioBlockDeviceConfiguration(attachment: try! VZDiskImageStorageDeviceAttachment(url: URL(fileURLWithPath: image.path), readOnly: image.isReadOnly))
//                        }
//
//                        let config = VZVirtualMachineConfiguration(configuration)
//                        config.storageDevices = storageDevices
//
//                        let pipeForReadingFromVM = Pipe()
//                        let pipeForWritingToVM = Pipe()
//
//                        let serialOut = VZVirtioConsoleDeviceSerialPortConfiguration()
//                        serialOut.attachment = VZFileHandleSerialPortAttachment(fileHandleForReading: pipeForWritingToVM.fileHandleForReading, fileHandleForWriting: pipeForReadingFromVM.fileHandleForWriting)
//                        config.serialPorts = [serialOut]
//
//                        let bootLoader = VZLinuxBootLoader(kernelURL: URL(fileURLWithPath: linuxBoot.kernelPath))
//                        bootLoader.commandLine = linuxBoot.commandLine
//                        bootLoader.initialRamdiskURL = URL(fileURLWithPath: linuxBoot.initialRamdiskPath)
//                        config.bootLoader = bootLoader
//
//                        try! config.validate()
//
//                        machine = VZVirtualMachine(configuration: config)
//                        machine?.start(completionHandler: { result in NSLog("Machine started: \(result)") })
//
//                        let consoleView = ConsoleView(fileHandleToReadFrom: pipeForReadingFromVM.fileHandleForReading, fileHandleToWriteTo: pipeForWritingToVM.fileHandleForWriting)
//                        let window = NSWindow(rootView: consoleView)
//                        Task {
//                            window.title = "Terminal"
//                            window.setContentSize(NSSize(width: 800, height: 600))
//                            window.makeKeyAndOrderFront(nil)
//                        }
//                    }
//                }
//                Spacer()
//            }
//            Spacer()
//        }
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentView(document: Binding.constant(MicroverseDocument()))
    }
}
