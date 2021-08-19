//
//  PortMessages.swift
//  PortMessages
//
//  Created by Justin Spahr-Summers on 19/08/2021.
//

import Foundation

enum MicroverseMessage: Codable {
    case paste(content: String)
}
