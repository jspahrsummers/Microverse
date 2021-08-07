//
//  AttachedDiskImage.swift
//  AttachedDiskImage
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import Foundation

struct AttachedDiskImage: Codable {
    var path: String = ""
    var isReadOnly: Bool = true
}
