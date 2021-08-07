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
        VStack {
            GroupBox("Startup Disk") {
                if let startupDiskURL = virtualMachine.startupDiskURL {
                    Text("\(startupDiskURL.path)")
                } else {
                    DiskCreationView { url, bytes in
                        let blockSize: UInt64 = 4096
                        do {
                            let process = Process()
                            process.launchPath = "/bin/dd"
                            process.arguments = [
                                "if=/dev/zero",
                                "of=\(url.path)",
                                "bs=\(blockSize)",
                                "seek=\(bytes / blockSize)",
                                "count=0"
                            ]
                            try process.run()
                            process.waitUntilExit()
                            
                            virtualMachine.startupDiskURL = url
                        } catch {
                            NSLog("Failed to create disk image")
                        }
                    }
                }
            }
            
            if virtualMachine.startupDiskURL != nil {
                VirtualMachineConfigurationView(configuration: $virtualMachine.configuration)
            }
        }
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
