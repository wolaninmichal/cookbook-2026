//
//  CoreDataStack.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 07/02/2026.
//

import Foundation
import CoreData

final class CoreDataStack: CoreDataStackProtocol {
    let persistentContainer: NSPersistentContainer
    
    init(
        modelName: String = "PersistenceCoreDataTodoList",
        inMemory: Bool = false
    ) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        if inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            persistentContainer.persistentStoreDescriptions = [description]
        }
        
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData setup fatal error with \(error)")
            }
        }
        
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
    }
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    func saveContextIfNeeded(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }

        if !context.insertedObjects.isEmpty {
            try context.obtainPermanentIDs(for: Array(context.insertedObjects))
        }

        try context.save()
    }

}
