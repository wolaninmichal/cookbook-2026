//
//  NetworkError.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import Foundation
import Moya

enum NetworkError: LocalizedError {
    case encoding(Error)
    case decoding(Error)
    case moya(MoyaError)
    
    var errorDescription: String? {
        switch self {
        case .encoding(let error):
            return "Błąd kodowania: \(error.localizedDescription)"
        case .decoding(let error):
            return "Błąd dekodowania: \(error.localizedDescription)"
        case .moya(let moyaError):
            return moyaError.localizedDescription
        }
    }
}
