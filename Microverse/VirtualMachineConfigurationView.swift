//
//  VirtualMachineConfigurationView.swift
//  VirtualMachineConfigurationView
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import SwiftUI


struct VirtualMachineConfigurationView: View {
    @State private var CPUCount: Double
    @State private var memoryMB: Double
    
    init(_ configuration: VirtualMachineConfiguration = VirtualMachineConfiguration()) {
        CPUCount = Double(configuration.CPUCount)
        memoryMB = Double(configuration.memoryMB)
    }
    
    public var configuration: VirtualMachineConfiguration {
        return VirtualMachineConfiguration(CPUCount: Int(CPUCount), memoryMB: UInt64(memoryMB))
    }
    
    var body: some View {
        Form {
            Section {
                Slider(value: $CPUCount, in: Double(VirtualMachineConfiguration.minimumCPUCount)...Double(VirtualMachineConfiguration.maximumCPUCount), step: 1) {
                } minimumValueLabel: {
                    Text("\(VirtualMachineConfiguration.minimumCPUCount)")
                } maximumValueLabel: {
                    Text("\(VirtualMachineConfiguration.maximumCPUCount)")
                }
                Text(CPUCount > 1 ? "\(Int(CPUCount)) CPUs" : "1 CPU").foregroundColor(Color.blue)
            }
            Section {
                Slider(value: $memoryMB, in: Double(VirtualMachineConfiguration.minimumMemoryMB)...Double(VirtualMachineConfiguration.maximumMemoryMB), step: 256) {
                } minimumValueLabel: {
                    Text("\(VirtualMachineConfiguration.minimumMemoryMB) MB")
                } maximumValueLabel: {
                    Text("\(VirtualMachineConfiguration.maximumMemoryMB) MB")
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
