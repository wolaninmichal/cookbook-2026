//
//  RealmManager.swift
//  PersistenceRealmTodoList
//
//  Created by Michał Wolanin on 10/02/2026.
//

import Foundation
import RealmSwift

protocol RealmManaging {
    func objects<T: Object>(_ type: T.Type) throws -> Results<T>
    func objects<T: Object>(_ type: T.Type, predicate: NSPredicate?) throws -> Results<T>
    
    func add<T: Object>(_ object: T, update: Realm.UpdatePolicy) throws
    func add<T: Object>(_ objects: [T], update: Realm.UpdatePolicy) throws
    
    func delete<T: Object>(_ object: T) throws
    func delete<T: Object>(_ objects: Results<T>) throws
    
    func write(_ block: (Realm) throws -> Void) throws
}

final class RealmManager: RealmManaging {
    private let configuration: Realm.Configuration
    
    init(
        configuraion: Realm.Configuration = .defaultConfiguration
    ) {
        self.configuration = configuraion
    }
    
    private func realm() throws -> Realm {
        return try Realm(configuration: configuration)
    }
    
    // MARK: - Objects
    func objects<T: Object>(_ type: T.Type) throws -> Results<T> {
        let realm = try! realm()
        return realm.objects(type)
    }
    
    func objects<T: Object>(_ type: T.Type, predicate: NSPredicate?) throws -> Results<T> {
        let realm = try! realm()
        var results = realm.objects(type)
        
        if let predicate = predicate {
            results = results.filter(predicate)
        }
        
        return results
    }
    
    // MARK: - Write helpers
    func add<T: Object>(_ object: T, update: Realm.UpdatePolicy = .modified) throws {
        let realm = try! realm()
        try! realm.write({
            realm.add(object, update: update)
        })
    }
    
    func add<T: Object>(_ objects: [T], update: Realm.UpdatePolicy = .modified) throws {
        let realm = try realm()
        try! realm.write {
            realm.add(objects, update: update)
        }
    }
    
    // MARK: - Delete helpers
    func delete<T: Object>(_ object: T) throws {
        let realm = try! realm()
        try! realm.write({
            realm.delete(object)
        })
    }
    
    func delete<T: Object>(_ objects: Results<T>) throws {
        let realm = try! realm()
        try! realm.write({
            realm.delete(objects)
        })
    }
    
    //MARK: - Write helpers
    func write(_ block: (Realm) throws -> Void) throws {
        let realm = try! realm()
        try realm.write {
            try block(realm)
        }
    }
}
