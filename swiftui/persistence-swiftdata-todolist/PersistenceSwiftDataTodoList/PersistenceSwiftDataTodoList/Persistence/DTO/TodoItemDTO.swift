//
//  TodoItemDTO.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 20/02/2026.
//

import Foundation
import SwiftData

struct TodoItemDTO: Identifiable, Equatable {
    let id: PersistentIdentifier
    let title: String
    let isDone: Bool
    let createdAt: Date
}
