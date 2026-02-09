//
//  CoreDataStackPersistence.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 08/02/2026.
//

import Foundation
import CoreData

protocol CoreDataStackProtocol: AnyObject {
    var viewContext: NSManagedObjectContext { get }
    func saveContextIfNeeded(context: NSManagedObjectContext) throws
    
    func newBackgroundContext() -> NSManagedObjectContext
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
}
