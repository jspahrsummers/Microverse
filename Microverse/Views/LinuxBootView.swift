//
//  LinuxBootView.swift
//  LinuxBootView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct LinuxBootViewModel {
    var kernelPath = ""
    var commandLine = "console=hvc0 root=/dev/vda1"
    var initialRamdiskPath = ""
}

struct LinuxBootView: View {
    @Binding var viewModel: LinuxBootViewModel
    
    var body: some View {
        HStack {
            Form {
                PathField(title: "Path to Kernel (vmlinux):", path: $viewModel.kernelPath, allowedContentTypes: [UTType.data])
                PathField(title: "Path to Initial RAM Disk (initrd):", path: $viewModel.initialRamdiskPath, allowedContentTypes: [UTType.data])
                TextField("Command Line Arguments:", text: $viewModel.commandLine)
            }
        }
    }
}

struct LinuxBootView_Previews: PreviewProvider {
    struct Holder: View {
        @State var viewModel = LinuxBootViewModel()
        var body: some View {
            return LinuxBootView(viewModel: $viewModel)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
