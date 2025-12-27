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
            return "Nie udało się zbudować URL."
        case .invalidResponse:
            return "Nieprawidłowa odpowiedź z serwera."
        case .transport(let error):
            return "Błąd połączenia: \(error.localizedDescription)"
        case .httpStatus(let code, _):
            return "Błąd serwera (HTTP \(code))."
        case .emptyBody:
            return "Brak danych w odpowiedzi."
        case .decoding(let error):
            return "Błąd dekodowania: \(error.localizedDescription)"
        case .encoding(let error):
            return "Błąd kodowania: \(error.localizedDescription)"
        }
    }
}
