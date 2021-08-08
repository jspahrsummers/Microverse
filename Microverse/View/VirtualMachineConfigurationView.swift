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
        GroupBox(label: Text("Virtual Machine")) {
            HStack {
                Form {
                    #if swift(>=5.5)
                    Picker("CPUs:", selection: $configuration.CPUCount) {
                        ForEach(VirtualMachineConfiguration.minimumCPUCount...VirtualMachineConfiguration.maximumCPUCount, id: \.self) { count in
                            Text("\(count)")
                        }
                    }
                    
                    Slider(value: Binding(get: { Float(configuration.memoryMB) }, set: { v in configuration.memoryMB = UInt64(v) }), in: Float(VirtualMachineConfiguration.minimumMemoryMB)...Float(VirtualMachineConfiguration.maximumMemoryMB), step: 256) {
                        Text("Memory:")
                    } minimumValueLabel: {
                        Text("\(VirtualMachineConfiguration.minimumMemoryMB) MB")
                    } maximumValueLabel: {
                        Text("\(VirtualMachineConfiguration.maximumMemoryMB) MB")
                    }
                    HStack {
                        Spacer()
                        Text("\(Int(configuration.memoryMB)) MB").foregroundColor(Color.blue)
                        Spacer()
                    }
                    #endif
                }
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
