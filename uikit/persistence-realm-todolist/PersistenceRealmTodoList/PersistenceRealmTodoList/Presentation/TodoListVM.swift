//
//  TodoListVM.swift
//  PersistenceRealmTodoList
//
//  Created by Michał Wolanin on 10/02/2026.
//

import RealmSwift
import UIKit
import Realm

protocol TodoListViewModelInput {
    func viewDidLoad()
    func addTask(title: String)
    func toggleTask(at indexPath: IndexPath)
    func deleteTask(at indexPath: IndexPath)
}

protocol TodoListViewModelOutput {
    var numberOfItems: Int { get }
    func item(at indexPath: IndexPath) -> TodoItem
    var onChange: ((TodoListChange) -> Void)? { get set }
}

typealias TodoListViewModelType = TodoListViewModelInput & TodoListViewModelOutput

enum TodoListChange {
    case initial
    case update(deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath])
    case error(Error)
}

@MainActor
final class TodoListVM: TodoListViewModelType {

    //MARK: - Output
    private(set) var items: Results<TodoItem>?
    var onChange: ((TodoListChange) -> Void)?
    
    //MARK: - Dependencie
    private let repository: TodoRepositoryProtocol
    private var notificationToken: NotificationToken?
    
    //MARK: - Init
    init(repository: TodoRepositoryProtocol){
        self.repository = repository
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    //MARK: - Input
    func viewDidLoad() {
        do {
            items = try repository.fetchAll()
            observeChanges()
        } catch {
            onChange?(.error(error))
        }
    }
    
    func addTask(title: String) {
        do {
            try repository.add(title: title)
        } catch {
            onChange?(.error(error))
        }
    }
    
    func toggleTask(at indexPath: IndexPath) {
        guard let item = items?[indexPath.row] else { return }
        do {
           try repository.toggleDone(item: item)
        } catch {
            onChange?(.error(error))
        }
    }
    
    func deleteTask(at indexPath: IndexPath) {
        guard let item = items?[indexPath.row] else { return }
        do {
           try repository.delete(item: item)
        } catch {
            onChange?(.error(error))
        }
    }
    
    //MARK: - Output
    var numberOfItems: Int {
        return items?.count ?? 0
    }
    
    func item(at indexPath: IndexPath) -> TodoItem {
        guard let item = items?[indexPath.row] else {
            fatalError("Index out of range!")
        }
        return item
    }
    
    //MARK: - Private
    private func observeChanges() {
        guard let items = items else { return }
        
        notificationToken = items.observe { [weak self] changes in
            guard let self = self else { return }
            
            switch changes {
            case .initial:
                self.onChange?(.initial)
                
            case .update(_, let deletions, let insertions, let modifications):
                let section = 0
                let deletionIPs = deletions.map { IndexPath(row: $0, section: section) }
                let insertionIPs = insertions.map { IndexPath(row: $0, section: section) }
                let modificationIPs = modifications.map { IndexPath(row: $0, section: section) }
                
                self.onChange?(
                    .update(
                        deletions: deletionIPs,
                        insertions: insertionIPs,
                        modifications: modificationIPs
                    )
                )
                
            case .error(let error):
                self.onChange?(.error(error))
            }
        }
    }
}
