//
//  TodoPayloads.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 20/12/2025.
//

import Foundation

struct TodoUpsertPayload: Encodable {
    let title: String
    let isDone: Bool
    let createdAt: Date
}
