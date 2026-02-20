//
//  HomeViewModel.swift
//  PersistenceSwiftDataTodoList
//
//  Created by Michał Wolanin on 20/02/2026.
//

import Foundation
import SwiftData
import Observation

@MainActor
@Observable
final class HomeViewModel {

    var items: [TodoItemDTO] = []
    var errorMessage: String?

    @ObservationIgnored private let repository: TodoRepositoryProtocol
    @ObservationIgnored private let context: ModelContext
    @ObservationIgnored private var didSaveTask: Task<Void, Never>?

    init(repository: TodoRepositoryProtocol, context: ModelContext) {
        self.repository = repository
        self.context = context
    }

    deinit { didSaveTask?.cancel() }

    func onAppear() {
        reload()
        observeContextDidSaveIfNeeded()
    }

    @discardableResult
    func addTask(title: String) -> Bool {
        do {
            try repository.add(title: title)
            return true
        } catch {
            errorMessage = "\(error)"
            return false
        }
    }

    func toggleTask(id: PersistentIdentifier) {
        do {
            try repository.toggleDone(id: id)
        } catch {
            errorMessage = "\(error)"
        }
    }

    func deleteTask(id: PersistentIdentifier) {
        do {
            try repository.delete(id: id)
        } catch {
            errorMessage = "\(error)"
        }
    }

    // MARK: - Private
    private func reload() {
        do {
            items = try repository.fetchAll()
        } catch {
            errorMessage = "\(error)"
        }
    }

    private func observeContextDidSaveIfNeeded() {
        guard didSaveTask == nil else { return }

        didSaveTask = Task { [weak self] in
            guard let self else { return }

            for await note in NotificationCenter.default.notifications(named: ModelContext.didSave) {
                /// filter only ours context
                guard (note.object as AnyObject?) === self.context else { continue }
                await MainActor.run { self.reload() }
            }
        }
    }
}
