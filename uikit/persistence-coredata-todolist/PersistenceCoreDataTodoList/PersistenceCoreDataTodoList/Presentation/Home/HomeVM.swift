//
//  HomeVM.swift
//  PersistenceCoreDataTodoList
//
//  Created by Michał Wolanin on 07/02/2026.
//

import UIKit
import CoreData

@MainActor
final class HomeVM: NSObject {

    // MARK: - Types
    typealias SectionID = HomeModels.SectionID
    typealias ItemID = HomeModels.ItemID
    typealias Snapshot = HomeModels.Snapshot

    // MARK: - Output
    var onSnapshot: ((Snapshot) -> Void)?
    var onError: ((Error) -> Void)?

    // MARK: - Dependencies
    private let repository: TodoCDRepositoryProtocol
    private var frc: NSFetchedResultsController<TodoItem>?

    // MARK: - State
    private var dtoCache: [NSManagedObjectID: TodoItemDTO] = [:]

    // MARK: - Init
    init(repository: TodoCDRepositoryProtocol) {
        self.repository = repository
        super.init()
    }

    deinit { frc?.delegate = nil }

    // MARK: - Lifecycle
    func viewDidLoad() {
        let frc = repository.makeFetchedResultsController()
        frc.delegate = self
        self.frc = frc

        do {
            try frc.performFetch()
            emitInitialSnapshot()
        } catch {
            onError?(error)
        }
    }

    // MARK: - Actions
    func addTask(title: String) {
        do { try repository.add(title: title) }
        catch { onError?(error) }
    }

    func toggleTask(objectID: NSManagedObjectID) {
        do { try repository.toggleDone(objectID: objectID) }
        catch { onError?(error) }
    }

    func deleteTask(objectID: NSManagedObjectID) {
        do { try repository.delete(objectID: objectID) }
        catch { onError?(error) }
    }

    // MARK: - data for UI
    func dto(for objectID: NSManagedObjectID) throws -> TodoItemDTO {
        if let cached = dtoCache[objectID] { return cached }
        let dto = try repository.fetchDTO(objectID: objectID)
        dtoCache[objectID] = dto
        return dto
    }

    // MARK: - Snapshot
    private func emitInitialSnapshot() {
        guard let frc else { return }

        let sectionName = frc.sections?.first?.name ?? ""
        let ids: [NSManagedObjectID] = (frc.fetchedObjects ?? []).map(\.objectID)

        var snapshot = Snapshot()
        snapshot.appendSections([sectionName])
        snapshot.appendItems(ids, toSection: sectionName)

        dtoCache.removeAll(keepingCapacity: true)
        onSnapshot?(snapshot)
    }

    private func invalidateCache(validIDs: [NSManagedObjectID], changedIDs: [NSManagedObjectID]) {
        let valid = Set(validIDs)
        dtoCache = dtoCache.filter { valid.contains($0.key) }
        changedIDs.forEach { dtoCache[$0] = nil }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension HomeVM: NSFetchedResultsControllerDelegate {
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChangeContentWith snapshotReference: NSDiffableDataSourceSnapshotReference
    ) {
        let snapshot: Snapshot = snapshotReference as Snapshot

        var changed: [NSManagedObjectID] = []

        if let reloaded = snapshotReference.reloadedItemIdentifiers as? [NSManagedObjectID] {
            changed.append(contentsOf: reloaded)
        }

        if #available(iOS 15.0, *),
           let reconfigured = snapshotReference.reconfiguredItemIdentifiers as? [NSManagedObjectID] {
            changed.append(contentsOf: reconfigured)
        }

        invalidateCache(validIDs: snapshot.itemIdentifiers, changedIDs: changed)
        onSnapshot?(snapshot)
    }
}
