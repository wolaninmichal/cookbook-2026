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

        print("➡️ \(method) \(url)")

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("Headers: \(headers)")
        }

        if let body, !body.isEmpty {
            print("Body: \(refactorJSONString(from: body) ?? string(from: body) ?? "<\(body.count) bytes>")")
        }
    }

    static func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?) {
        guard isEnabled else { return }

        if let error {
            print("❌ Transport error: \(error.localizedDescription)")
            return
        }

        guard let response else {
            print("❌ No HTTPURLResponse")
            return
        }

        print("⬅️ HTTP \(response.statusCode) \(response.url?.absoluteString ?? "")")

        if let data, !data.isEmpty {
            print("Response: \(refactorJSONString(from: data) ?? string(from: data) ?? "<\(data.count) bytes>")")
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

