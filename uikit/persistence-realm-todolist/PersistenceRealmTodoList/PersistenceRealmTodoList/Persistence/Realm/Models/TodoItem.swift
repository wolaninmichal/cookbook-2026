//
//  TodoItem.swift
//  PersistenceRealmTodoList
//
//  Created by Michał Wolanin on 10/02/2026.
//

import Foundation
import RealmSwift

final class TodoItem: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String
    @Persisted var isDone: Bool
    @Persisted var createdAt: Date
    
    convenience init(title: String) {
        self.init()
        self.title = title
        self.isDone = false
        self.createdAt = Date()
    }
}
