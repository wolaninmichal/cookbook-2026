//
//  TodoAPI.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

enum TodoAPI: Endpoint {
    case list
    case create
    case update(id: String)
    case delete(id: String)

    var scheme: HTTPScheme { .https }
    var host: String { "crudcrud.com" }

    var headers: [String : String] { Headers().from([.accept, .contentType]) }

    var path: String {
        let base = "/api/\(CrudCrudConfig.token)/\(CrudCrudConfig.resource)"
        switch self {
        case .list, .create:
            return base
        case .update(let id), .delete(let id):
            return "\(base)/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list: return .get
        case .create: return .post
        case .update: return .put
        case .delete: return .delete
        }
    }
    
    var queryItems: [URLQueryItem] { [] }
}
