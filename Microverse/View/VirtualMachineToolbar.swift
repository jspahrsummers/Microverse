//
//  VirtualMachineToolbar.swift
//  VirtualMachineToolbar
//
//  Created by Justin Spahr-Summers on 12/08/2021.
//

import SwiftUI

struct VirtualMachineToolbar: View {
    var virtualMachineController: VirtualMachineController
    
    var body: some View {
        Spacer()
        GroupBox("Clipboard") {
            HStack {
                Button("Copy from VM") {
                    
                }
                Button("Paste into VM") {
                    
                }
            }
        }
        Spacer()
    }
}
