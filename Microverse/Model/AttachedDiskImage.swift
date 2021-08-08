//
//  AttachedDiskImage.swift
//  AttachedDiskImage
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import Foundation
import Virtualization

struct AttachedDiskImage: Codable, Equatable, Hashable {
    enum SynchronizationMode: String, Codable, Equatable, Hashable, CaseIterable, Identifiable {
        case full = "Full"
        case fsync = "fsync-only"
        case none = "None"
        
        var id: String {
            self.rawValue
        }
    }
    
    var path: String = ""
    var isReadOnly: Bool = true
    var synchronizationMode: SynchronizationMode = .fsync
}

extension VZDiskImageSynchronizationMode {
    init(_ mode: AttachedDiskImage.SynchronizationMode) {
        switch mode {
        case .full:
            self = .full
        case .fsync:
            self = .fsync
        case .none:
            self = .none
        }
    }
}
