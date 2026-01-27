//
//  TodoUpsertPayloadc.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/01/2026.
//

import Foundation

/// DTO do POST/PUT bez `_id`
struct TodoUpsertPayload: Encodable {
    let title: String
    let isDone: Bool
    let createdAt: Date
}
