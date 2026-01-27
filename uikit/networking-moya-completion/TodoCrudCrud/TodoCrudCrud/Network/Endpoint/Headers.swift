//
//  Headers.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import Foundation

enum HeaderParameters {
    case accept
    case contentType
    
    var value: [String: String] {
        switch self {
        case .accept:
            return ["Accept": "application/json"]
        case .contentType:
            return ["Content-Type": "application/json"]
        }
    }
}

struct Headers {
    func params(_ params: [HeaderParameters]) -> [String: String] {
        let values = Dictionary(
            params.flatMap { $0.value }) { _, last in
                last
            }
        return values
    }
}
