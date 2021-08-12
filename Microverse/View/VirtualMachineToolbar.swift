//
//  VirtualMachineToolbar.swift
//  VirtualMachineToolbar
//
//  Created by Justin Spahr-Summers on 12/08/2021.
//

import AppKit
import SwiftUI

struct VirtualMachineToolbar: View {
    var virtualMachineController: VirtualMachineController
    
    var body: some View {
        Spacer()
        GroupBox("Clipboard") {
            HStack {
                Button("Copy from VM") {
                    NSLog("Unimplemented")
                }
                Button("Paste into VM") {
                    guard let data = NSPasteboard.general.data(forType: .string) else {
                        NSLog("Host pasteboard is empty")
                        return
                    }
                    
                    guard let content = String(data: data, encoding: .utf8) else {
                        NSLog("Could not decode string data on host pasteboard")
                        return
                    }
                    
                    Task {
                        do {
                            try await virtualMachineController.pasteIntoVM(content)
                        } catch {
                            NSLog("Paste error: \(error)")
                        }
                    }
                }
            }
        }
        Spacer()
    }
}
