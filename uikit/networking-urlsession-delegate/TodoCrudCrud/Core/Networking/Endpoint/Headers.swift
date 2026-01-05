//
//  Headers.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/12/2025.
//

import Foundation

enum HeaderParams {
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
    func from(_ params: [HeaderParams]) -> [String: String]{
        let values = Dictionary(
            params.flatMap({ $0.value }),
            uniquingKeysWith: { (_, last) in last }
        )
        return values
    }
}
