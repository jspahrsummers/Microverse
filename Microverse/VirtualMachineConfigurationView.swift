//
//  VirtualMachineConfigurationView.swift
//  VirtualMachineConfigurationView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI

struct VirtualMachineConfigurationView: View {
    @Binding var configuration: VirtualMachineConfiguration
    
    var body: some View {
        Form {
            Section {
                Slider(value: Binding(get: { Double(configuration.CPUCount) }, set: { v in configuration.CPUCount = Int(v) }), in: Double(VirtualMachineConfiguration.minimumCPUCount)...Double(VirtualMachineConfiguration.maximumCPUCount), step: 1) {
                } minimumValueLabel: {
                    Text("\(VirtualMachineConfiguration.minimumCPUCount)")
                } maximumValueLabel: {
                    Text("\(VirtualMachineConfiguration.maximumCPUCount)")
                }
                Text(configuration.CPUCount > 1 ? "\(Int(configuration.CPUCount)) CPUs" : "1 CPU").foregroundColor(Color.blue)
            }
            Section {
                Slider(value: Binding(get: { Double(configuration.memoryMB) }, set: { v in configuration.memoryMB = UInt64(v) }), in: Double(VirtualMachineConfiguration.minimumMemoryMB)...Double(VirtualMachineConfiguration.maximumMemoryMB), step: 256) {
                } minimumValueLabel: {
                    Text("\(VirtualMachineConfiguration.minimumMemoryMB) MB")
                } maximumValueLabel: {
                    Text("\(VirtualMachineConfiguration.maximumMemoryMB) MB")
                }
                Text("\(Int(configuration.memoryMB)) MB").foregroundColor(Color.blue)
            }
        }
    }
}

struct VirtualMachineConfigurationView_Previews: PreviewProvider {
    struct Holder: View {
        @State var configuration = VirtualMachineConfiguration()
        var body: some View {
            VirtualMachineConfigurationView(configuration: $configuration)
        }
    }
    
    static var previews: some View {
        Holder()
    }
}
