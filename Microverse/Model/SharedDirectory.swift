//
//  SharedDirectory.swift
//  SharedDirectory
//
//  Created by Justin Spahr-Summers on 08/08/2021.
//

import Foundation

struct SharedDirectory: Codable, Equatable, Hashable {
    var path: String = ""
    var isReadOnly: Bool = false
}
