//
//  MicroverseErrors.swift
//  MicroverseErrors
//
//  Created by Justin Spahr-Summers on 08/08/2021.
//

import Foundation

enum MicroverseError: Error {
    case guestOSServicesNotFound
    case noSocketDevice
    case stringEncodingError
    case vmNotFoundOnNetwork
    case guestOSServiceOperationFailed
    case guestOSServiceFailedToStart
}
