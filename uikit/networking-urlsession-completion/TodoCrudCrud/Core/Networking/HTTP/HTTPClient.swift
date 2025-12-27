//
//  HTTPClient.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

protocol HTTPClient {
    /// `bez body, z Decodable response`
    /// używana np. do GET
    func send<Response: Decodable>(
        _ endpoint: Endpoint,
        
        decoder: JSONDecoder,
        completion: @escaping (Result<Response, Error>) -> Void
    )

    /// `z body, z Decodable response`
    /// używana np. do POST
    func send<Body: Encodable, Response: Decodable>(
        _ endpoint: Endpoint,
        
        body: Body,
        encoder: JSONEncoder,
        
        decoder: JSONDecoder,
        completion: @escaping (Result<Response, Error>) -> Void
    )

    /// `bez body, bez response body`
    /// używana np. do DELETE
    func send(
        _ endpoint: Endpoint,
        
        completion: @escaping (Result<Void, Error>) -> Void
    )

    /// `z body, bez response body`
    /// używana np. do PUT
    func send<Body: Encodable>(
        _ endpoint: Endpoint,
        
        body: Body,
        encoder: JSONEncoder,
        
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

extension HTTPClient {
    func send<Response: Decodable>(
        _ endpoint: Endpoint,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        send(endpoint, decoder: JSONCoding.decoder, completion: completion)
    }

    func send<Body: Encodable, Response: Decodable>(
        _ endpoint: Endpoint,
        body: Body,
        completion: @escaping (Result<Response, Error>) -> Void
    ) {
        send(endpoint, body: body, encoder: JSONCoding.encoder, decoder: JSONCoding.decoder, completion: completion)
    }

    func send<Body: Encodable>(
        _ endpoint: Endpoint,
        body: Body,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        send(endpoint, body: body, encoder: JSONCoding.encoder, completion: completion)
    }
}
