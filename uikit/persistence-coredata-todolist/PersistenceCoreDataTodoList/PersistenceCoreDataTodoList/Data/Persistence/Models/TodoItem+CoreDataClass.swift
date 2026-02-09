//
//  TodoItem.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 07/02/2026.
//

import Foundation
import CoreData

@objc(TodoItem)
final class TodoItem: NSManagedObject {  }

extension TodoItem {
    @nonobjc class func fetchRequest() -> NSFetchRequest<TodoItem> {
        NSFetchRequest<TodoItem>(entityName: "TodoItem")
    }
    
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var isDone: Bool
    @NSManaged var createdAt: Date
}
