//
//  URLSessionDelegateHTTPClient.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/12/2025.
//

import Foundation

protocol HTTPRequestDelegate: AnyObject {
    /// streaming - progressing chunks of data as they arrive
    func request(_ id: UUID, didReceive data: Data)
    /// final result - the HTTP response + the full body (the body may be empty for PUT/DELETE).
    func request(_ id: UUID, didCompleteWith result: Result<(HTTPURLResponse, Data), Error>)
}

extension HTTPRequestDelegate {
    func request(_ id: UUID, didReceive data: Data) { /* default no-op */ }
}
