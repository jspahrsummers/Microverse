//
//  VirtualMachineController.swift
//  VirtualMachineController
//
//  Created by Justin Spahr-Summers on 08/08/2021.
//

import Foundation
import Virtualization

final class VirtualMachineController: NSObject, VZVirtualMachineDelegate {
    let dispatchQueue = DispatchQueue(label: "com.metacognitive.Microverse.VirtualMachineController", qos: .userInitiated, attributes: .init(), autoreleaseFrequency: .workItem)
    let virtualMachine: VZVirtualMachine
    
    init(configuration: VZVirtualMachineConfiguration) throws {
        try configuration.validate()
        virtualMachine = VZVirtualMachine(configuration: configuration, queue: dispatchQueue)
    }
    
    func start() async throws {
        try await withCheckedThrowingContinuation { cont in
            dispatchQueue.async {
                self.virtualMachine.start { result in cont.resume(with: result) }
            }
        }
    }
    
    func guestDidStop(_ virtualMachine: VZVirtualMachine) {
        
    }
    
    func virtualMachine(_ virtualMachine: VZVirtualMachine, didStopWithError error: Error) {
        
    }
}
