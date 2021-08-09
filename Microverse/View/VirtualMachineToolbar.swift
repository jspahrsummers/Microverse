//
//  VirtualMachineToolbar.swift
//  VirtualMachineToolbar
//
//  Created by Justin Spahr-Summers on 09/08/2021.
//

import AppKit
import SwiftUI

struct VirtualMachineToolbar: View {
    var virtualMachineController: VirtualMachineController? = nil
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        Spacer()
        HStack {
            Spacer()
            Form {
                TextField(text: $username) {
                    Text("Username")
                }
                SecureField(text: $password) {
                    Text("Password")
                }
            }
            GroupBox("Clipboard") {
                VStack {
                    Button("Host → VM") {
                        guard let pasteboardContents = NSPasteboard.general.string(forType: .string) else {
                            return
                        }
                        
                        do {
                            try virtualMachineController?.pasteIntoVM(pasteboardContents, username: username, password: password)
                        } catch {
                            NSLog("Pasting error: \(error)")
                        }
                    }
                    Button("VM → Host") {
                    
                    }
                }
            }
            Spacer()
        }
        Spacer()
    }
}

struct VirtualMachineToolbar_Previews: PreviewProvider {
    static var previews: some View {
        VirtualMachineToolbar()
    }
}
