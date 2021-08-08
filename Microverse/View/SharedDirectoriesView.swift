//
//  SharedDirectoriesView.swift
//  SharedDirectoriesView
//
//  Created by Justin Spahr-Summers on 08/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct SharedDirectoryView: View {
    @Binding var sharedDirectory: SharedDirectory
    
    var body: some View {
        PathField(title: "", path: $sharedDirectory.path, allowedContentTypes: [UTType.directory])
        Toggle("Read only", isOn: $sharedDirectory.isReadOnly)
    }
}

struct SharedDirectoriesView: View {
    @Binding var sharedDirectories: [SharedDirectory]
    
    var body: some View {
        GroupBox("Shared Directories") {
            HStack {
                Form {
                    ForEach(Array($sharedDirectories.enumerated()), id: \.offset) { index, element in
                        HStack {
                            Button("Remove") {
                                sharedDirectories.remove(at: index)
                            }
                            Spacer()
                            SharedDirectoryView(sharedDirectory: $sharedDirectories[index])
                        }
                    }
                    HStack {
                        Spacer()
                        Button("Add") {
                            sharedDirectories.append(SharedDirectory())
                        }
                    }
                }
            }
        }
    }
}

struct SharedDirectoriesView_Previews: PreviewProvider {
    struct Holder: View {
        @State var sharedDirectories: [SharedDirectory] = []
        var body: some View {
            SharedDirectoriesView(sharedDirectories: $sharedDirectories)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
