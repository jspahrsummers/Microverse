//
//  VirtualMachine.swift
//  VirtualMachine
//
//  Created by Justin Spahr-Summers on 02/08/2021.
//

import Foundation

protocol VirtualMachine: Codable {
    var uniqueIdentifier: UUID { get }
    
    init()
}
