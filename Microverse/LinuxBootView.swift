//
//  LinuxBootView.swift
//  LinuxBootView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI

struct LinuxBootViewModel {
    var kernelPath = ""
    var commandLine = "console=hvc0 root=/dev/vda1"
    var initialRamdiskPath = ""
}

struct LinuxBootView: View {
    @Binding var viewModel: LinuxBootViewModel
    
    var body: some View {
        Form {
            TextField("Path to Kernel", text: $viewModel.kernelPath)
            TextField("Path to initial RAM disk", text: $viewModel.initialRamdiskPath)
            TextField("Command line arguments", text: $viewModel.commandLine)
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
