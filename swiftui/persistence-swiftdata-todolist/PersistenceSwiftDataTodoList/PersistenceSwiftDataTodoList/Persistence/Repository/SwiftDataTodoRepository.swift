//
//  SwiftDataTodoRepository.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 20/02/2026.
//

import Foundation
import SwiftData

protocol TodoRepositoryProtocol {
    func fetchAll() throws -> [TodoItemDTO]
    func add(title: String) throws
    func toggleDone(id: PersistentIdentifier) throws
    func delete(id: PersistentIdentifier) throws
}

final class SwiftDataTodoRepository: TodoRepositoryProtocol {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [TodoItemDTO] {
        let descriptor = FetchDescriptor<TodoItem>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let items = try context.fetch(descriptor)
        return items.map {
            TodoItemDTO(
                id: $0.persistentModelID,
                title: $0.title,
                isDone: $0.isDone,
                createdAt: $0.createdAt
            )
        }
    }

    func add(title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        context.insert(TodoItem(title: trimmed))
        try context.save()
    }

    func toggleDone(id: PersistentIdentifier) throws {
        let item = try fetchItem(id: id)
        item.isDone.toggle()
        try context.save()
    }

    func delete(id: PersistentIdentifier) throws {
        let item = try fetchItem(id: id)
        context.delete(item)
        try context.save()
    }

    private func fetchItem(id: PersistentIdentifier) throws -> TodoItem {
        let predicate = #Predicate<TodoItem> { $0.persistentModelID == id }
        let descriptor = FetchDescriptor<TodoItem>(predicate: predicate)

        guard let item = try context.fetch(descriptor).first else {
            throw TodoRepositoryError.notFound
        }
        return item
    }
}
