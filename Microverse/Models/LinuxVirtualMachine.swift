//
//  LinuxVirtualMachine.swift
//  LinuxVirtualMachine
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import Foundation

struct LinuxVirtualMachine: Codable {
    let uniqueIdentifier: UUID
    
    init() {
        self.init(uniqueIdentifier: UUID())
    }
    
    init(uniqueIdentifier: UUID) {
        self.uniqueIdentifier = uniqueIdentifier
    }
}
