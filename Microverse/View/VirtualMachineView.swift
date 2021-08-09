//
//  VirtualMachineView.swift
//  VirtualMachineView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import Virtualization

#if swift(>=5.5)

@available(macOS 12.0, *)
struct VirtualMachineView: NSViewRepresentable {
    var virtualMachine: VZVirtualMachine?
    
    func makeNSView(context: Context) -> VZVirtualMachineView {
        let view = VZVirtualMachineView()
        view.capturesSystemKeys = true
        view.virtualMachine = virtualMachine
        return view
    }
    
    func updateNSView(_ nsView: VZVirtualMachineView, context: Context) {
        nsView.virtualMachine = virtualMachine
    }
}

#endif
