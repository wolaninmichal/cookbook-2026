//
//  Todo.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 20/12/2025.
//

import Foundation

struct Todo: Codable, Hashable, Identifiable {
    
    let id: String
    var title: String
    var isDone: Bool
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case isDone
        case createdAt
    }
}
