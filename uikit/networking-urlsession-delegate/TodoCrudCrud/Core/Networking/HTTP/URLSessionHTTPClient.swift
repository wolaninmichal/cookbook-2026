//
//  URLSessionHTTPClient.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 21/12/2025.
//

import Foundation

final class URLSessionHTTPClient: NSObject, HTTPClient {
    /// state for a single request, holding:
    /// - `requestID` to help distinguish concurrent requests,
    /// - `delegate` as `weak`,
    /// - `buffer` where chunks are accumulated until completion.
    private final class TaskContext {
        let requestID: UUID
        weak var delegate: HTTPRequestDelegate?

        var response: HTTPURLResponse?
        var buffer: Data = .init()

        init(requestID: UUID, delegate: HTTPRequestDelegate) {
            self.requestID = requestID
            self.delegate = delegate
        }
    }

    private var session: URLSession!
    /// a single place to dispatch delegate callbacks
    private let callbackQueue: DispatchQueue

    private var contexts: [Int: TaskContext] = [:]
    /// protectds `contexts` from race conditions, because URLSession callbacks may arrive concurrently
    /// and Dictionary is not thread-safe.
    private let lock: NSLock = .init()

    init(
        config: URLSessionConfiguration = .default,
        callbackQueue: DispatchQueue = .main
    ) {
        self.callbackQueue = callbackQueue
        super.init()
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    // MARK: - HTTPClient
    func send(
        _ endpoint: Endpoint,
        requestID: UUID,
        delegate: HTTPRequestDelegate
    ) {
        perform(endpoint, body: nil, requestID: requestID, delegate: delegate)
    }

    func send<Body: Encodable>(
        _ endpoint: Endpoint,
        body: Body,
        encoder: JSONEncoder,
        requestID: UUID,
        delegate: HTTPRequestDelegate
    ) {
        do {
            let data = try encoder.encode(body)
            perform(endpoint, body: data, requestID: requestID, delegate: delegate)
        } catch {
            callbackQueue.async {
                Log.error("encode FAIL | requestID=\(requestID) | err=\(error.localizedDescription)")
                delegate.request(requestID, didCompleteWith: .failure(NetworkError.encoding(error)))
            }
        }
    }

    // MARK: - core
    private func perform(
        _ endpoint: Endpoint,
        body: Data?,
        requestID: UUID,
        delegate: HTTPRequestDelegate
    ) {
        let request: URLRequest
        do {
            request = try URLRequestBuilder(endpoint: endpoint).createURLRequest(body: body)
        } catch {
            /// If request building failed, immediately report failure to the delegate.
            /// We always call the delegate on a single predictable queue (usually `.main`, so it's UI-safe),
            /// which is why we dispatch via `callbackQueue`.
            /// This way, the service/VM doesn't have to guess which thread the result will arrive on.
            callbackQueue.async {
                Log.error("build request FAIL | requestID=\(requestID) | err= \(error.localizedDescription)")
                delegate.request(requestID, didCompleteWith: .failure(error))
            }
            return
        }

        NetworkLogger.logRequest(request, body: body)

        let task = session.dataTask(with: request)

        /// `important`
        let ctx = TaskContext(requestID: requestID, delegate: delegate)
        storeContext(ctx, for: task.taskIdentifier)

        let method = request.httpMethod ?? "?"
        let url = request.url?.absoluteString ?? "nil"
        Log.network("start | requestID=\(requestID) | task=\(task.taskIdentifier) | \(method) \(url)")

        task.resume()
    }

    private func storeContext(_ ctx: TaskContext, for taskId: Int) {
        lock.lock()
        defer { lock.unlock() }
        contexts[taskId] = ctx
    }
    
    private func context(for taskID: Int) -> TaskContext? {
        lock.lock()
        defer { lock.unlock() }
        return contexts[taskID]
    }

    private func removeContext(for taskID: Int) -> TaskContext? {
        lock.lock()
        defer { lock.unlock() }
        return contexts.removeValue(forKey: taskID)
    }
}

// MARK: - URLSessionDataDelegate
extension URLSessionHTTPClient: URLSessionDataDelegate {

    /// Callback fired when URLSession has received the response headers (status code + headers)
    /// and wants to know whether it should continue downloading the body.
    ///
    /// The method receives a `URLResponse`.
    /// For HTTP it will almost always be an `HTTPURLResponse`, so we cast it.
    /// At this point the body may not be available yet.
    ///
    /// `completionHandler` MUST be called, otherwise the task will stall at this stage.
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void
    ) {

        /// We look up the context by `taskIdentifier`,
        /// which is a unique Int assigned by URLSession to each task.
        ///
        /// We keep a dictionary `contexts: [Int: TaskContext]` so that in URLSession callbacks,
        /// we can find our request context:
        ///   - requestID (UUID)
        ///   - delegate (HTTPRequestDelegate)
        ///   - buffer (accumulated data)
        ///   - response (HTTPURLResponse)
        guard let ctx = context(for: dataTask.taskIdentifier) else {
            /// If there is no context, it means:
            /// - the task was already removed from the map (e.g. canceled / completed / race),
            /// - or a logic bug: we never stored the context.
            completionHandler(.cancel)
            return
        }

        /// Store the response in the context.
        ///
        /// `ctx.response` is `HTTPURLResponse?` and provides:
        /// - statusCode (e.g. 200, 404, 500)
        /// - allHeaderFields (headers)
        /// - url
        ctx.response = response as? HTTPURLResponse

        let url = dataTask.originalRequest?.url?.absoluteString ?? "nil"
        let code = (ctx.response?.statusCode).map(String.init) ?? "?"
        Log.network("didReceive response | requestID=\(ctx.requestID) | task=\(dataTask.taskIdentifier) | code=\(code) | url=\(url)")

        completionHandler(.allow)
    }

    /// Callback fired when a portion of the response body arrives.
    /// This may be called multiple times (chunking).
    /// For small responses it often arrives once, but you must not rely on that.
    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        guard let ctx = context(for: dataTask.taskIdentifier) else { return }

        /// `ctx.buffer`:
        /// - grows with each received chunk
        /// - should contain the full body at the end (in didComplete)
        ctx.buffer.append(data)

        Log.network("didReceive chunk | requestID=\(ctx.requestID) | task=\(dataTask.taskIdentifier) | chunk=\(data.count)B | total=\(ctx.buffer.count)B")

        /// Delegate is weak — it may be released if nobody retains it.
        if let delegate = ctx.delegate {
            /// Use `callbackQueue` so all delegate callbacks happen on a known thread/queue (main in this case).
            callbackQueue.async {
                delegate.request(ctx.requestID, didReceive: data)
            }
        }
    }

    /// Final callback when the task finishes (successfully or with an error).
    /// At this point we know:
    /// - whether there was a transport error,
    /// - the final status code,
    /// - the full body (ctx.buffer).
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        /// Take the context and remove it from the dictionary.
        ///
        /// Why remove?
        /// - to avoid memory leaks
        /// - to ensure a later callback (if any) won't use stale context
        guard let ctx = removeContext(for: task.taskIdentifier) else { return }

        let total = ctx.buffer.count
        let response = ctx.response

        /// A:
        /// `error` means URLSession failed at the transport layer.
        if let error {
            Log.error("didComplete ERROR | requestID=\(ctx.requestID) | task=\(task.taskIdentifier) | total=\(total)B | err=\(error.localizedDescription)")
            callbackQueue.async {
                ctx.delegate?.request(ctx.requestID, didCompleteWith: .failure(NetworkError.transport(error)))
            }
            return
        }

        /// B:
        /// `didReceive response` should have set `ctx.response`.
        /// If it's missing:
        /// - it wasn't an HTTP response, or
        /// - `didReceive response` never arrived / the task got canceled, or
        /// - logic bug.
        guard let http = response else {
            Log.error("didComplete invalidResponse | requestID=\(ctx.requestID) | task=\(task.taskIdentifier) | total=\(total)B")
            callbackQueue.async {
                ctx.delegate?.request(ctx.requestID, didCompleteWith: .failure(NetworkError.invalidResponse))
            }
            return
        }

        /// C:
        let code = http.statusCode
        guard (200...299).contains(code) else {
            Log.warning("didComplete HTTP \(code) | requestID=\(ctx.requestID) | task=\(task.taskIdentifier) | total=\(total)B")
            let body = ctx.buffer.isEmpty ? nil : ctx.buffer
            callbackQueue.async {
                ctx.delegate?.request(ctx.requestID, didCompleteWith: .failure(NetworkError.httpStatus(code, body: body)))
            }
            return
        }

        /// D:
        /// Return:
        /// - http: HTTPURLResponse (status, headers),
        /// - ctx.buffer: Data (full body).
        Log.info("didComplete OK | requestID=\(ctx.requestID) | task=\(task.taskIdentifier) | code=\(code) | total=\(total)B")
        callbackQueue.async {
            ctx.delegate?.request(ctx.requestID, didCompleteWith: .success((http, ctx.buffer)))
        }
    }
}
