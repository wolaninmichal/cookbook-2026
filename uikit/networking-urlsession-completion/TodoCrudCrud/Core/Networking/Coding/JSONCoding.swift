//
//  JSONCoding.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

enum JSONCoding {
    static let decoder: JSONDecoder = {
        let d: JSONDecoder = .init()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    static let encoder: JSONEncoder = {
        let e: JSONEncoder = .init()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
}
