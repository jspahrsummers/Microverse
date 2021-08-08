//
//  AttachedDisksView.swift
//  AttachedDisksView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct AttachedDiskView: View {
    var label: String
    @Binding var diskImage: AttachedDiskImage
    
    var body: some View {
        PathField(title: label, path: $diskImage.path, allowedContentTypes: [UTType.diskImage])
        HStack {
            Picker("Synchronization Mode:", selection: $diskImage.synchronizationMode) {
                ForEach(AttachedDiskImage.SynchronizationMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            Toggle("Read Only", isOn: $diskImage.isReadOnly)
        }
    }
}

struct AttachedDisksView: View {
    @Binding var diskImages: [AttachedDiskImage]
    
    var body: some View {
        GroupBox(label: Text("Attached Disks")) {
            HStack {
                Form {
                    #if swift(>=5.5)
                    ForEach(Array($diskImages.enumerated()), id: \.offset) { index, element in
                        AttachedDiskView(label: "Disk Image \(index + 1):", diskImage: $diskImages[index])
                        HStack {
                            Spacer()
                            Button("Remove") {
                                diskImages.remove(at: index)
                            }
                        }
                    }
                    #endif
                    HStack {
                        Spacer()
                        Button("Add") {
                            diskImages.append(AttachedDiskImage())
                        }
                    }
                }
            }
        }
    }
}

struct AttachedDisksView_Previews: PreviewProvider {
    struct Holder: View {
        @State var disks: [AttachedDiskImage] = [AttachedDiskImage()]
        var body: some View {
            return AttachedDisksView(diskImages: $disks)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
