//
//  main.swift
//  MicroverseGuestOSService
//
//  Created by Justin Spahr-Summers on 10/08/2021.
//

import Foundation
import GRPC
import NIO

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
defer {
    try! group.syncShutdownGracefully()
}

let provider = GuestOSServiceProvider()
let server = Server.insecure(group: group)
    .withServiceProviders([provider])
    .bind(host: "localhost", port: Int(guestOSServicePortNumber))

server.map {
    $0.channel.localAddress
}.whenSuccess { address in
    print("Server started: \(address!)")
}

_ = try server.flatMap {
    $0.onClose
}.wait()
