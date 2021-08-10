//
//  VirtualizationExtensions.swift
//  VirtualizationExtensions
//
//  Created by Justin Spahr-Summers on 10/08/2021.
//

import Foundation
import Virtualization

#if arch(arm64)

extension VZMacOSRestoreImage {
    class func load(from url: URL) async throws -> VZMacOSRestoreImage {
        return try await withCheckedThrowingContinuation { cont in
            VZMacOSRestoreImage.load(from: url) { result in
                cont.resume(with: result)
            }
        }
    }
    
    class func fetchLatestSupported() async throws -> VZMacOSRestoreImage {
        return try await withCheckedThrowingContinuation { cont in
            VZMacOSRestoreImage.fetchLatestSupported { result in
                cont.resume(with: result)
            }
        }
    }
}

#endif
