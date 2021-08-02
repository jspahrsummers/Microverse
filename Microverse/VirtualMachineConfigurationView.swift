//
//  VirtualMachineConfigurationView.swift
//  VirtualMachineConfigurationView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI
import Virtualization

struct VirtualMachineConfigurationView: View {
    static let minimumCPUCount = VZVirtualMachineConfiguration.minimumAllowedCPUCount
    static let maximumCPUCount = VZVirtualMachineConfiguration.maximumAllowedCPUCount
    static let minimumMemoryMB = max(VZVirtualMachineConfiguration.minimumAllowedMemorySize / 1024 / 1024, 256)
    static let maximumMemoryMB = VZVirtualMachineConfiguration.maximumAllowedMemorySize / 1024 / 1024
    
    @State private var CPUCount = Double(minimumCPUCount)
    @State private var memoryMB = Double(minimumMemoryMB)
    
    var body: some View {
        Form {
            Section {
                Slider(value: $CPUCount, in: Double(VirtualMachineConfigurationView.minimumCPUCount)...Double(VirtualMachineConfigurationView.maximumCPUCount), step: 1) {
                } minimumValueLabel: {
                    Text("\(VirtualMachineConfigurationView.minimumCPUCount)")
                } maximumValueLabel: {
                    Text("\(VirtualMachineConfigurationView.maximumCPUCount)")
                }
                Text(CPUCount > 1 ? "\(Int(CPUCount)) CPUs" : "1 CPU").foregroundColor(Color.blue)
            }
            Section {
                Slider(value: $memoryMB, in: Double(VirtualMachineConfigurationView.minimumMemoryMB)...Double(VirtualMachineConfigurationView.maximumMemoryMB), step: 256) {
                } minimumValueLabel: {
                    Text("\(VirtualMachineConfigurationView.minimumMemoryMB) MB")
                } maximumValueLabel: {
                    Text("\(VirtualMachineConfigurationView.maximumMemoryMB) MB")
                }
                Text("\(Int(memoryMB)) MB").foregroundColor(Color.blue)
            }
        }
    }
}

struct VirtualMachineConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VirtualMachineConfigurationView()
        }
    }
}
