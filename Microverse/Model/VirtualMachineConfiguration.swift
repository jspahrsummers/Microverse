//
//  VirtualMachineConfiguration.swift
//  VirtualMachineConfiguration
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import AVFoundation
import Foundation
import Virtualization

struct VirtualMachineConfiguration: Codable, Equatable {
    static let minimumCPUCount = VZVirtualMachineConfiguration.minimumAllowedCPUCount
    static let maximumCPUCount = VZVirtualMachineConfiguration.maximumAllowedCPUCount
    static let minimumMemoryMB = max(VZVirtualMachineConfiguration.minimumAllowedMemorySize / 1024 / 1024, 256)
    static let maximumMemoryMB = VZVirtualMachineConfiguration.maximumAllowedMemorySize / 1024 / 1024
    
    public var CPUCount = min(max(2, minimumCPUCount), maximumCPUCount)
    public var memoryMB = min(max(4096, minimumMemoryMB), maximumMemoryMB)
}

extension VZVirtualMachineConfiguration {
    convenience init(_ config: VirtualMachineConfiguration) {
        self.init()
        self.cpuCount = config.CPUCount
        self.memorySize = config.memoryMB * 1024 * 1024
        self.memoryBalloonDevices = [VZVirtioTraditionalMemoryBalloonDeviceConfiguration()]
        self.entropyDevices = [VZVirtioEntropyDeviceConfiguration()]
        self.pointingDevices = [VZUSBScreenCoordinatePointingDeviceConfiguration()]
        self.keyboards = [VZUSBKeyboardConfiguration()]
        
        let network = VZVirtioNetworkDeviceConfiguration()
        network.attachment = VZNATNetworkDeviceAttachment()
        self.networkDevices = [network]
        
        let audioOut = VZVirtioSoundDeviceOutputStreamConfiguration()
        audioOut.sink = VZHostAudioOutputStreamSink()
        
        AVCaptureDevice.requestAccess(for: .audio) { _ in }
        
        let audioIn = VZVirtioSoundDeviceInputStreamConfiguration()
        audioIn.source = VZHostAudioInputStreamSource()
        
        let audioDevice = VZVirtioSoundDeviceConfiguration()
        audioDevice.streams = [audioIn, audioOut]
        self.audioDevices = [audioDevice]
    }
}
