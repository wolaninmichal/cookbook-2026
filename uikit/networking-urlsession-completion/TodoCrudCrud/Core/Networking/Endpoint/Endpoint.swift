//
//  Endpoint.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 26/12/2025.
//

import Foundation

protocol Endpoint {
    var scheme: HTTPScheme { get }
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
}

extension Endpoint {
    var queryItems: [URLQueryItem] { [] }
    var headers: [String: String] { [:] }
}

