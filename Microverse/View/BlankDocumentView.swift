//
//  BlankDocumentView.swift
//  BlankDocumentView
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import SwiftUI

enum BlankDocumentVMPlatform: String, CaseIterable {
    case macOS = "macOS"
    case linux = "Linux"
}

struct BlankDocumentView: View {
    @State var platform: BlankDocumentVMPlatform = .linux
    var action: (BlankDocumentVMPlatform) -> ()
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Form {
                    if #available(macOS 12.0, *) {
#if swift(>=5.5)
                        Picker("Platform:", selection: $platform) {
                            ForEach(BlankDocumentVMPlatform.allCases, id: \.self) { platform in
                                Text(platform.rawValue)
                            }
                        }.submitScope()
#endif
                    }
                    Button("Create") {
                        action(platform)
                    } .keyboardShortcut(.defaultAction)
                }
                Spacer()
            }
            Spacer()
        }
    }
}

struct BlankDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        BlankDocumentView() { _ in }
    }
}
