//
//  TodoRepository.swift
//  PersistenceRealmTodoList
//
//  Created by Michał Wolanin on 10/02/2026.
//

import RealmSwift

protocol TodoRepositoryProtocol {
    func fetchAll() throws -> Results<TodoItem>
    func add(title: String) throws
    func toggleDone(item: TodoItem) throws
    func delete(item: TodoItem) throws
}

final class RealmTodoRepository: TodoRepositoryProtocol {
    private let realmManager: RealmManaging
    
    init(
        realmManager: RealmManaging
    ) {
        self.realmManager = realmManager
    }
    
    func fetchAll() throws -> Results<TodoItem> {
        let results = try realmManager.objects(TodoItem.self)
        return results.sorted(byKeyPath: "createdAt", ascending: true)
    }
    
    func add(title: String) throws {
        let item = TodoItem(title: title)
        try realmManager.add(item, update: .all)
    }
    
    func toggleDone(item: TodoItem) throws {
        try realmManager.write { _ in
            item.isDone.toggle()
        }
    }
    
    func delete(item: TodoItem) throws {
        try realmManager.delete(item)
    }
    
}
