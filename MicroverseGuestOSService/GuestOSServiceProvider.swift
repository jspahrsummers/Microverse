//
//  GuestOSServiceProvider.swift
//  GuestOSServiceProvider
//
//  Created by test on 10/08/2021.
//

import AppKit
import Foundation
import GRPC
import NIO

final class GuestOSServiceProvider: Microverse_GuestOSServiceProvider {
    var interceptors: Microverse_GuestOSServiceServerInterceptorFactoryProtocol?
    
    func paste(request: Microverse_PasteRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Microverse_PasteResponse> {
        let pboard = NSPasteboard.general
        pboard.clearContents()
        pboard.setData(request.content.data(using: .utf8), forType: .string)
        return context.eventLoop.makeSucceededFuture(Microverse_PasteResponse.with { $0.success = true })
    }
}
