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

extension MicroverseMessage {
    init(fromPortMessage message: PortMessage) throws {
        guard let messageData = message.components?.first as? Data else {
            throw MicroverseError.guestOSServiceMessageDecodingFailed(message: message)
        }
        
        self = try PropertyListDecoder().decode(MicroverseMessage.self, from: messageData)
    }
}

extension PortMessage {
    convenience init(send: Port?, receive: Port?, microverseMessage message: MicroverseMessage) throws {
        let data = try PropertyListEncoder().encode(message)
        self.init(send: send, receive: receive, components: [data])
    }
    
    func send(before date: Date, qos: Dispatch.DispatchQoS.QoSClass) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            DispatchQueue.global(qos: qos).async {
                if self.send(before: date) {
                    cont.resume(returning: ())
                } else {
                    cont.resume(throwing: MicroverseError.failedToSendPortMessage(message: self))
                }
            }
        }
    }
}
