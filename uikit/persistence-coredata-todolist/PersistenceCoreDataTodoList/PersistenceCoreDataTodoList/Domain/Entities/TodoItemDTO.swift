//
//  TodoItemDTO.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 08/02/2026.
//

import Foundation
import CoreData

struct TodoItemDTO: Equatable {
    let objectID: NSManagedObjectID
    let title: String
    let isDone: Bool
    let createdAt: Date
}
