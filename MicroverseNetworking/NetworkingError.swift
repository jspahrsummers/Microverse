//
//  NetworkingError.swift
//  NetworkingError
//
//  Created by Justin Spahr-Summers on 22/08/2021.
//

import Foundation

public enum NetworkingError: Error {
    case messageDecodingFailed(message: PortMessage)
    case failedToSendPortMessage(message: PortMessage)
}
