//
//  AttachedDiskImage.swift
//  AttachedDiskImage
//
//  Created by Justin Spahr-Summers on 07/08/2021.
//

import Foundation
import Virtualization

struct AttachedDiskImage: Equatable, Hashable {
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

extension AttachedDiskImage: Codable {
    enum CodingKeys: String, CodingKey {
        case path = "data"
        case isReadOnly
        case synchronizationMode
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bookmarkForURL: URL(fileURLWithPath: path), options: isReadOnly ? [.withSecurityScope, .securityScopeAllowOnlyReadAccess] : .withSecurityScope, forKey: .path)
        try container.encode(isReadOnly, forKey: .isReadOnly)
        try container.encode(synchronizationMode, forKey: .synchronizationMode)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        var stale = false
        let url = try values.decodeURLFromBookmark(options: .withSecurityScope, forKey: .path, stale: &stale)
        
        // FIXME: This is imbalanced right now!
        guard url.startAccessingSecurityScopedResource() else {
            throw CocoaError(.fileReadNoPermission)
        }
        
        path = url.path
        isReadOnly = try values.decode(Bool.self, forKey: .isReadOnly)
        
        if let synchronizationMode = try values.decodeIfPresent(SynchronizationMode.self, forKey: .synchronizationMode) {
            self.synchronizationMode = synchronizationMode
        }
    }
}

#if swift(>=5.5)
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
#endif
