//
//  HTTPClient.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

protocol HTTPClient {
    /// The result does not come back via a closure — it will be delivered later to the delegate
    /// (and it may arrive in multiple chunks).
    /// `requestID` is required so the delegate can correlate callbacks when multiple requests run in parallel.
    func send(
        _ endpoint: Endpoint,
        requestID: UUID,
        delegate: HTTPRequestDelegate
    )

    /// Same as above, but additionally the client encodes `Body` into JSON (`encoder`)
    /// and sends it as the HTTP body.
    /// `encoder` is a parameter so you can control encoding details (e.g. date strategy)
    /// without hard-coding configuration inside the client.
    func send<Body: Encodable>(
        _ endpoint: Endpoint,
        body: Body,
        encoder: JSONEncoder,
        requestID: UUID,
        delegate: HTTPRequestDelegate
    )
}

extension HTTPClient {
    /// Convenience overload that uses the default JSON encoder.
    /// You still have access to the version that accepts a custom `encoder` when needed.
    func send<Body: Encodable>(
        _ endpoint: Endpoint,
        body: Body,
        requestID: UUID,
        delegate: HTTPRequestDelegate
    ) {
        send(endpoint, body: body, encoder: JSONCoding.encoder, requestID: requestID, delegate: delegate)
    }
}

