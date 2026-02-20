//
//  SwiftDataStack.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 20/02/2026.
//

import SwiftData

protocol SwiftDataStackProtocol: AnyObject {
    var container: ModelContainer { get }
    var mainContext: ModelContext { get }
    func makeBackgroundContext() -> ModelContext
}

final class SwiftDataStack: SwiftDataStackProtocol {

    let container: ModelContainer
    let mainContext: ModelContext

    init(inMemory: Bool = false) throws {
        let schema = Schema([TodoItem.self])
        let config = ModelConfiguration("TodoStore", schema: schema, isStoredInMemoryOnly: inMemory)

        self.container = try ModelContainer(for: schema, configurations: [config])
        self.mainContext = ModelContext(container)
    }

    func makeBackgroundContext() -> ModelContext {
        ModelContext(container)
    }
}
