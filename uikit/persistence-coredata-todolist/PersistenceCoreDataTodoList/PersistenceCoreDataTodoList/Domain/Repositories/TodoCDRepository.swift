//
//  TodoRepository.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 07/02/2026.
//

import Foundation
import CoreData

protocol TodoCDRepositoryProtocol {
    func makeFetchedResultsController() -> NSFetchedResultsController<TodoItem>

    func add(title: String) throws
    func toggleDone(objectID: NSManagedObjectID) throws
    func delete(objectID: NSManagedObjectID) throws

    func fetchDTO(objectID: NSManagedObjectID) throws -> TodoItemDTO
}

final class TodoCDRepository: TodoCDRepositoryProtocol {
    private let stack: CoreDataStackProtocol
    
    init(stack: CoreDataStackProtocol) {
        self.stack = stack
    }
    
    private var viewContext: NSManagedObjectContext { stack.viewContext }
    
    func makeFetchedResultsController() -> NSFetchedResultsController<TodoItem> {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TodoItem.createdAt), ascending: true)
        ]
        request.fetchBatchSize = 50
                            
        return NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
    }
    
    func add(title: String) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let item = TodoItem(context: viewContext)
        item.id = UUID()
        item.title = trimmed
        item.isDone = false
        item.createdAt = Date()
        
        try stack.saveContextIfNeeded(context: viewContext)
    }
    
    func toggleDone(objectID: NSManagedObjectID) throws {
        let obj = try viewContext.existingObject(with: objectID)
        guard let item = obj as? TodoItem else { return }
        
        item.isDone.toggle()
        try stack.saveContextIfNeeded(context: viewContext)
    }
    
    func delete(objectID: NSManagedObjectID) throws {
        let obj = try viewContext.existingObject(with: objectID)
        guard let item = obj as? TodoItem else { return }
        
        viewContext.delete(item)
        try stack.saveContextIfNeeded(context: viewContext)
    }
    
    func fetchDTO(objectID: NSManagedObjectID) throws -> TodoItemDTO {
        let obj = try viewContext.existingObject(with: objectID)
        guard let item = obj as? TodoItem else {
            struct MappingError: Error {}
            throw MappingError()
        }
        
        return TodoItemDTO(
            objectID: objectID,
            title: item.title,
            isDone: item.isDone,
            createdAt: item.createdAt
        )
    }
}
