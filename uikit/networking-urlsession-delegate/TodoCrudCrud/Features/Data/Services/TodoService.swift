//
//  TodoService.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

/// Receives typed results from TodoService operations.
/// Default implementations below make each callback optional.
protocol TodoServiceDelegate: AnyObject {
    func todoService(_ service: TodoServiceProtocol, didFetchAll result: Result<[Todo], Error>)
    func todoService(_ service: TodoServiceProtocol, didCreate  result: Result<Todo, Error>)
    func todoService(_ service: TodoServiceProtocol, didUpdate  result: Result<Void, Error>)
    func todoService(_ service: TodoServiceProtocol, didDelete  result: Result<Void, Error>)
}

extension TodoServiceDelegate {
    /// Optional callback
    func todoService(_ service: TodoServiceProtocol, didFetchAll result: Result<[Todo], Error>) {}
    /// Optional callback
    func todoService(_ service: TodoServiceProtocol, didCreate result: Result<Todo, Error>) {}
    /// Optional callback
    func todoService(_ service: TodoServiceProtocol, didUpdate result: Result<Void, Error>) {}
    /// Optional callback
    func todoService(_ service: TodoServiceProtocol, didDelete result: Result<Void, Error>) {}
}

/// Public API of the service layer.
/// This layer turns raw HTTP callbacks into typed domain results.
protocol TodoServiceProtocol: AnyObject {
    func fetchAll(delegate: TodoServiceDelegate)
    func create(title: String, isDone: Bool, delegate: TodoServiceDelegate)
    func update(todo: Todo, delegate: TodoServiceDelegate)
    func delete(id: String, delegate: TodoServiceDelegate)
}

final class TodoService: TodoServiceProtocol {
    private enum Operation {
        case fetchAll
        case create
        case update
        case delete
    }

    /// per-request context stored under `requestID`.
    /// It tells:
    /// - which logical operation this request belongs to,
    /// - which TodoServiceDelegate should receive the typed result.
    private final class OpContext {
        let op: Operation
        weak var delegate: TodoServiceDelegate?

        init(op: Operation, delegate: TodoServiceDelegate) {
            self.op = op
            self.delegate = delegate
        }
    }

    private let client: HTTPClient

    /// Operation context table:
    /// - requestID - operation + delegate to notify
    /// Needed because a single TodoService instance can run many concurrent requests,
    /// and HTTP callbacks arrive later, out of order.
    private var ops: [UUID: OpContext] = [:]

    /// Mutex protecting `ops` (Dictionary is NOT thread-safe).
    /// URLSession delegate callbacks can arrive on different threads,
    /// so reads/writes/removals must be synchronized.
    private let lock: NSLock = .init()

    init(client: HTTPClient) {
        self.client = client
    }

    // MARK: - Operations
    func fetchAll(delegate: TodoServiceDelegate) {
        start(op: .fetchAll, delegate: delegate) { requestID in
            client.send(TodoAPI.list, requestID: requestID, delegate: self)
        }
    }

    func create(title: String, isDone: Bool, delegate: TodoServiceDelegate) {
        let payload = TodoUpsertPayload(title: title, isDone: isDone, createdAt: Date())
        start(op: .create, delegate: delegate) { requestID in
            client.send(TodoAPI.create, body: payload, requestID: requestID, delegate: self)
        }
    }

    func update(todo: Todo, delegate: TodoServiceDelegate) {
        let payload = TodoUpsertPayload(title: todo.title, isDone: todo.isDone, createdAt: todo.createdAt)
        start(op: .update, delegate: delegate) { requestID in
            client.send(TodoAPI.update(id: todo.id), body: payload, requestID: requestID, delegate: self)
        }
    }

    func delete(id: String, delegate: TodoServiceDelegate) {
        start(op: .delete, delegate: delegate) { requestID in
            client.send(TodoAPI.delete(id: id), requestID: requestID, delegate: self)
        }
    }

    // MARK: - Helpers
    /// registers an operation context under a new requestID, then starts the HTTP request.
    ///
    /// Why lock here?
    /// - `ops` is a mutable Dictionary and not thread-safe.
    /// - Network callbacks can race with `start(...)` and `takeContext(...)`.
    /// - Lock guarantees only one thread mutates/reads `ops` at a time.
    private func start(op: Operation, delegate: TodoServiceDelegate, _ run: (UUID) -> Void) {
        let id: UUID = .init()

        lock.lock()
        defer { lock.unlock() }
        ops[id] = OpContext(op: op, delegate: delegate)

        run(id)
    }

    /// atomically removes and returns the stored context for a given requestID.
    private func takeContext(for id: UUID) -> OpContext? {
        lock.lock()
        defer { lock.unlock() }
        return ops.removeValue(forKey: id)
    }
}

// MARK: - HTTPRequestDelegate
extension TodoService: HTTPRequestDelegate {

    /// Final callback from the HTTP layer.
    /// We use `requestID` to find the stored OpContext, then:
    /// - decode/map raw Data into typed models (if needed),
    /// - call the correct TodoServiceDelegate method.
    func request(_ id: UUID, didCompleteWith result: Result<(HTTPURLResponse, Data), Error>) {
        guard let ctx = takeContext(for: id) else { return }

        switch ctx.op {

        case .fetchAll:
            let mapped: Result<[Todo], Error> = result.flatMap { _, data in
                do {
                    return .success(try JSONCoding.decoder.decode([Todo].self, from: data))
                } catch {
                    return .failure(NetworkError.decoding(error))
                }
            }
            ctx.delegate?.todoService(self, didFetchAll: mapped)

        case .create:
            let mapped: Result<Todo, Error> = result.flatMap { _, data in
                do {
                    return .success(try JSONCoding.decoder.decode(Todo.self, from: data))
                } catch {
                    return .failure(NetworkError.decoding(error))
                }
            }
            ctx.delegate?.todoService(self, didCreate: mapped)

        case .update:
            /// crudcrud typically returns an empty body for PUT — if HTTP is 2xx, treat as success.
            let mapped: Result<Void, Error> = result.map { _ in () }
            ctx.delegate?.todoService(self, didUpdate: mapped)

        case .delete:
            /// same idea for DELETE - success is based on HTTP status code.
            let mapped: Result<Void, Error> = result.map { _ in () }
            ctx.delegate?.todoService(self, didDelete: mapped)
        }
    }
}
