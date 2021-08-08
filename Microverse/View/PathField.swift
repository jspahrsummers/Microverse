//
//  PathField.swift
//  PathField
//
//  Created by Justin Spahr-Summers on 04/08/2021.
//

import SwiftUI
import UniformTypeIdentifiers

struct PathField: View {
    var title: String
    @Binding var path: String
    var allowedContentTypes: [UTType]
    @State var presentingFileImporter = false
    
    var body: some View {
        HStack {
            TextField(title, text: $path)
            Button("Locate…") {
                presentingFileImporter = true
            }.fileImporter(isPresented: $presentingFileImporter, allowedContentTypes: allowedContentTypes) { result in
                guard case let .success(URL) = result, URL.isFileURL else {
                    return
                }
                
                path = URL.path
            }
        }
    }
}

struct PathField_Previews: PreviewProvider {
    struct Holder: View {
        @State var path: String = ""
        var body: some View {
            PathField(title: "Path", path: $path, allowedContentTypes: [UTType.content])
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
