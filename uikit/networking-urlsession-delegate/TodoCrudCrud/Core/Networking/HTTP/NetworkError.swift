//
//  NetworkError.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case transport(Error)
    case httpStatus(Int, body: Data?)
    case emptyBody
    case decoding(Error)
    case encoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Failed to build the URL."
        case .invalidResponse:
            return "Invalid response from the server."
        case .transport(let error):
            return "Connection error: \(error.localizedDescription)"
        case .httpStatus(let code, _):
            return "Server error (HTTP \(code))."
        case .emptyBody:
            return "Empty response body."
        case .decoding(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encoding(let error):
            return "Encoding error: \(error.localizedDescription)"
        }
    }
}
