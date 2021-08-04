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
                Slider(value: Binding(get: { Float(configuration.CPUCount) }, set: { v in configuration.CPUCount = Int(v) }), in: Float(VirtualMachineConfiguration.minimumCPUCount)...Float(VirtualMachineConfiguration.maximumCPUCount), step: 1) {
                } minimumValueLabel: {
                    Text("\(VirtualMachineConfiguration.minimumCPUCount)")
                } maximumValueLabel: {
                    Text("\(VirtualMachineConfiguration.maximumCPUCount)")
                }
                Text(configuration.CPUCount > 1 ? "\(Int(configuration.CPUCount)) CPUs" : "1 CPU").foregroundColor(Color.blue)
            }
            Section {
                Slider(value: Binding(get: { Float(configuration.memoryMB) }, set: { v in configuration.memoryMB = UInt64(v) }), in: Float(VirtualMachineConfiguration.minimumMemoryMB)...Float(VirtualMachineConfiguration.maximumMemoryMB), step: 256) {
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
