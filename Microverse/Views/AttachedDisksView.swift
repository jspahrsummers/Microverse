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

extension AttachedDiskImage: Identifiable {
    var id: String { return path }
}

struct AttachedDiskView: View {
    @Binding var diskImage: AttachedDiskImage
    
    var body: some View {
        HStack {
            Form {
                PathField(title: "Attach Disk Image:", path: $diskImage.path, allowedContentTypes: [UTType.diskImage])
                Toggle("Read only", isOn: $diskImage.isReadOnly)
            }
        }
    }
}

struct AttachedDisksViewModel {
    var diskImages: [AttachedDiskImage] = [AttachedDiskImage()]
}

struct AttachedDisksView: View {
    @Binding var viewModel: AttachedDisksViewModel
    
    var body: some View {
        Form {
            ForEach($viewModel.diskImages) { diskImage in
                AttachedDiskView(diskImage: diskImage)
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
