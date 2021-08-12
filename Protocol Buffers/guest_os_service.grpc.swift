//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: guest_os_service.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import SwiftProtobuf


/// Usage: instantiate `Microverse_GuestOSServiceClient`, then call methods of this protocol to make API calls.
internal protocol Microverse_GuestOSServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Microverse_GuestOSServiceClientInterceptorFactoryProtocol? { get }

  func paste(
    _ request: Microverse_PasteRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Microverse_PasteRequest, Microverse_PasteResponse>
}

extension Microverse_GuestOSServiceClientProtocol {
  internal var serviceName: String {
    return "microverse.GuestOSService"
  }

  /// Unary call to Paste
  ///
  /// - Parameters:
  ///   - request: Request to send to Paste.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  internal func paste(
    _ request: Microverse_PasteRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Microverse_PasteRequest, Microverse_PasteResponse> {
    return self.makeUnaryCall(
      path: "/microverse.GuestOSService/Paste",
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makePasteInterceptors() ?? []
    )
  }
}

internal protocol Microverse_GuestOSServiceClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'paste'.
  func makePasteInterceptors() -> [ClientInterceptor<Microverse_PasteRequest, Microverse_PasteResponse>]
}

internal final class Microverse_GuestOSServiceClient: Microverse_GuestOSServiceClientProtocol {
  internal let channel: GRPCChannel
  internal var defaultCallOptions: CallOptions
  internal var interceptors: Microverse_GuestOSServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the microverse.GuestOSService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  internal init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Microverse_GuestOSServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol Microverse_GuestOSServiceProvider: CallHandlerProvider {
  var interceptors: Microverse_GuestOSServiceServerInterceptorFactoryProtocol? { get }

  func paste(request: Microverse_PasteRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Microverse_PasteResponse>
}

extension Microverse_GuestOSServiceProvider {
  internal var serviceName: Substring { return "microverse.GuestOSService" }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  internal func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "Paste":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Microverse_PasteRequest>(),
        responseSerializer: ProtobufSerializer<Microverse_PasteResponse>(),
        interceptors: self.interceptors?.makePasteInterceptors() ?? [],
        userFunction: self.paste(request:context:)
      )

    default:
      return nil
    }
  }
}

internal protocol Microverse_GuestOSServiceServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'paste'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makePasteInterceptors() -> [ServerInterceptor<Microverse_PasteRequest, Microverse_PasteResponse>]
}