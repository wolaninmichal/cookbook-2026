//
//  NetworkLogger.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/12/2025.
//

import Foundation

enum NetworkLogger {

    static var isEnabled: Bool = true

    static func logRequest(_ request: URLRequest, body: Data?) {
        guard isEnabled else { return }

        let method = request.httpMethod ?? "?"
        let url = request.url?.absoluteString ?? "nil"

        Log.network("➡️ \(method) \(url)")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            Log.network("Headers: \(headers)")
        }

        if let body, !body.isEmpty {
            let rendered = refactorJSONString(from: body) ?? string(from: body) ?? "<\(body.count) bytes>"
            Log.network("Body: \(rendered)")
        }
    }

    static func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?) {
        guard isEnabled else { return }

        if let error {
            Log.error("❌ Transport error: \(error.localizedDescription)")
            return
        }

        guard let response else {
            Log.error("❌ No HTTPURLResponse")
            return
        }

        Log.network("⬅️ HTTP \(response.statusCode) \(response.url?.absoluteString ?? "")")

        if let data, !data.isEmpty {
            let rendered = refactorJSONString(from: data) ?? string(from: data) ?? "<\(data.count) bytes>"
            Log.network("Response: \(rendered)")
        }
    }

    private static func refactorJSONString(from data: Data) -> String? {
        guard
            let json = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
            let str = String(data: pretty, encoding: .utf8)
        else { return nil }
        return str
    }

    private static func string(from data: Data) -> String? {
        String(data: data, encoding: .utf8)
    }
}
