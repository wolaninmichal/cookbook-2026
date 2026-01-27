//
//  TodoAPI.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import Foundation
import Moya
import Alamofire

enum TodoAPI {
    case list
    case create(body: Data)
    case update(id: String, body: Data)
    case delete(id: String)
}

extension TodoAPI: TargetType {
    
    var baseURL: URL {
        URL(string: "https://crudcrud.com")!
    }
    
    var path: String {
        let base = "/api/\(CrudCrudConfig.token)/\(CrudCrudConfig.resource)"
        switch self {
        case .list, .create:
            return base
        case .update(let id, _), .delete(let id):
            return "\(base)/\(id)"
        }
    }

    
    var method: Moya.Method {
        switch self {
        case .list:
            return .get
        case .create(let body):
            return .post
        case .update(let id, let body):
            return .put
        case .delete(let id):
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .list:
            return .requestPlain
        case .create(let body):
            return .requestData(body)
        case .update(let id, let body):
            return .requestData(body)
        case .delete(let id):
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        Headers().params([.accept, .contentType])
    }
    
    /// Validates HTTP status codes at the Moya level:
    /// - 2xx responses are treated as `.success`
    /// - non-2xx responses (e.g. 4xx/5xx) are returned as `.failure(MoyaError.statusCode(...))`
    /// This keeps service code simpler because we don't have to manually check `response.statusCode`.
    var validationType: ValidationType {
        .successCodes
    }
}
