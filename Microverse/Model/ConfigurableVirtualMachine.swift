//
//  ConfigurableVirtualMachine.swift
//  ConfigurableVirtualMachine
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import Foundation

protocol ConfigurableVirtualMachine {
    var configuration: VirtualMachineConfiguration { get set }
}
