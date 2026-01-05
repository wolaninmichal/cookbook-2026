//
//  Logs.swift
//  TodoCrudCrud
//
//  Created by Michał Wolanin on 27/12/2025.
//

import Foundation

enum LogType {
    case info
    case debug
    case warning
    case error
    case initObj
    case deinitObj
    case database
    case network

    var prefix: String {
        switch self {
        case .info: "INFO 💡"
        case .debug: "DEBUG 📖"
        case .warning: "WARNING 🧨"
        case .error: "ERROR 🔥"
        case .initObj: "INIT 🐣"
        case .deinitObj: "DEINIT 💀"
        case .database: "DATABASE 📤"
        case .network: "NETWORK 🌐"
        }
    }
}

struct Log {
    private static var defaultLogs: [LogType] = []
    public static func setLogTypes(_ types: [LogType]) { Log.defaultLogs = types }
    private static func shoudLog(_ type: LogType) -> Bool { defaultLogs.contains(type) }

    private static func printLog(prefix: String, data: String?, shouldPrint: Bool, force: Bool) {
        #if !ENV_PROD
        guard let string = data,
              force || shouldPrint else { return }
        print("\(prefix) \(string)")
        #endif
    }

    static func info(_ text: String?, force: Bool = false) { msg(.info, text, force: force) }
    static func debug(_ text: String?, force: Bool = false) { msg(.debug, text, force: force) }
    static func warning(_ text: String?, force: Bool = false) { msg(.warning, text, force: force)}
    static func error(_ text: String?, force: Bool = false) { msg(.error, text, force: force)}
    static func network(_ text: String?, force: Bool = false) { msg(.network, text, force: force) }

    static func deinitObject(_ anyObject: AnyObject) { msg(.deinitObj, "\(anyObject)")}
    static func initObject(_ anyObject: AnyObject) { msg(.initObj, "\(anyObject)")}

    static func msg(_ type: LogType, _ text: String?, force: Bool = false) {
        printLog(prefix: type.prefix, data: text, shouldPrint: shoudLog(type), force: force)
    }
}
