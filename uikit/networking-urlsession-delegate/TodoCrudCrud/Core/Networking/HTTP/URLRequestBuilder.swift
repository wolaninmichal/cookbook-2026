//
//  URLRequestBuilder.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

struct URLRequestBuilder {
    private let endpoint: Endpoint

    init(endpoint: Endpoint) {
        self.endpoint = endpoint
    }

    func createURLRequest(body: Data?) throws -> URLRequest {
        var components = URLComponents()
        components.scheme = endpoint.scheme.rawValue
        components.host = endpoint.host
        components.path = endpoint.path
        components.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = body

        endpoint.headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        return request
    }
}
