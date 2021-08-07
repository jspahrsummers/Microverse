//
//  AttachedDisksView.swift
//  AttachedDisksView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct AttachedDiskImage {
    var path: String = ""
    var isReadOnly: Bool = true
}

extension AttachedDiskImage {
    var id: String { return path }
}

struct AttachedDiskView: View {
    var label: String
    @Binding var diskImage: AttachedDiskImage
    
    var body: some View {
        PathField(title: label, path: $diskImage.path, allowedContentTypes: [UTType.diskImage])
        Toggle("Read only", isOn: $diskImage.isReadOnly)
    }
}

struct AttachedDisksViewModel {
    var diskImages: [AttachedDiskImage] = []
}

struct AttachedDisksView: View {
    @Binding var viewModel: AttachedDisksViewModel
    
    var body: some View {
        GroupBox("Attached Disks") {
            HStack {
                Form {
                    ForEach(Array($viewModel.diskImages.enumerated()), id: \.offset) { index, element in
                        HStack {
                            Button("Remove") {
                                viewModel.diskImages.remove(at: index)
                            }
                            Spacer()
                            AttachedDiskView(label: "Disk Image \(index + 1):", diskImage: $viewModel.diskImages[index])
                        }
                    }
                    HStack {
                        Spacer()
                        Button("Add") {
                            viewModel.diskImages.append(AttachedDiskImage())
                        }
                    }
                }
            }
        }
    }
}

struct AttachedDisksView_Previews: PreviewProvider {
    struct Holder: View {
        @State var viewModel = AttachedDisksViewModel()
        var body: some View {
            return AttachedDisksView(viewModel: $viewModel)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
