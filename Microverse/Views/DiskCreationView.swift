//
//  DiskCreationView.swift
//  DiskCreationView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct DiskCreationView: View {
    @State private var diskSizeGB: Float = 4
    var action: (URL, UInt64) -> ()
    
    var body: some View {
        let numberFormatter = NumberFormatter()
        
        HStack {
            Form {
                TextField("Disk Size (GB):", value: $diskSizeGB, formatter: numberFormatter)
                Button("Create…") {
                    let panel = NSSavePanel()
                    panel.allowedContentTypes = [UTType.diskImage]
                    panel.nameFieldStringValue = "disk.img"
                    panel.allowsOtherFileTypes = true
                    panel.canCreateDirectories = true
                    panel.begin { response in
                        guard response == NSApplication.ModalResponse.OK, let url = panel.url else {
                            return
                        }
                        
                        let bytes = UInt64(diskSizeGB * 1024 * 1024 * 1024)
                        action(url, bytes)
                    }
                }
            }
        }
    }
}

struct DiskCreationView_Previews: PreviewProvider {
    static var previews: some View {
        DiskCreationView() { _, _ in }
    }
}
