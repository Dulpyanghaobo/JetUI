//
//  CSLogger.swift
//  JetUI
//
//  统一日志系统，基于 OSLog
//

import Foundation
import OSLog

// MARK: - 日志类别

public enum LogCategory: String {
    case general      = "General"
    case `import`     = "Import"      // 文件 / 图片导入
    case thumbnail    = "Thumbnail"   // 缩略图生成
    case network      = "Network"     // 网络请求
    case database     = "Database"    // 持久化 / CoreData
    case ui           = "UI"          // 界面事件
    case auth         = "Auth"        // 认证相关
    case subscription = "Subscription" // 订阅相关

    public init(_ rawValue: String) {
        self = LogCategory(rawValue: rawValue) ?? .general
    }
}

public struct CSLogger {

    /// 可配置的 subsystem，默认使用 Bundle identifier
    public static var subsystem: String = Bundle.main.bundleIdentifier ?? "com.jetui.app"

    @inline(__always)
    private static func logger(for category: LogCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }

    @inline(__always)
    public static func debug(_ message: String, category: LogCategory = .general) {
        logger(for: category).debug("\(message, privacy: .public)")
    }

    @inline(__always)
    public static func info(_ message: String, category: LogCategory = .general) {
        logger(for: category).info("\(message, privacy: .public)")
    }

    @inline(__always)
    public static func notice(_ message: String, category: LogCategory = .general) {
        logger(for: category).notice("\(message, privacy: .public)")
    }

    @inline(__always)
    public static func warning(_ message: String, category: LogCategory = .general) {
        logger(for: category).warning("\(message, privacy: .public)")
    }

    @inline(__always)
    public static func error(_ message: String, category: LogCategory = .general) {
        logger(for: category).error("\(message, privacy: .public)")
    }

    @inline(__always)
    public static func fault(_ message: String, category: LogCategory = .general) {
        logger(for: category).fault("\(message, privacy: .public)")
    }

    // ------------------------------------------------------------------
    // MARK: Signpost 性能分析
    // ------------------------------------------------------------------
    // 用于测量代码片段耗时。例如：
    // ```swift
    // let id = CSLogger.signpost(.begin, category: .network, name: "Image Download")
    // ...
    // CSLogger.signpost(.end,   category: .network, name: "Image Download", signpostID: id)
    // ```
    @discardableResult
    public static func signpost(
        _ type: OSSignpostType,
        category: LogCategory = .general,
        name: StaticString,
        signpostID: OSSignpostID = .exclusive,
        _ msg: String = ""
    ) -> OSSignpostID {
        let log = OSLog(subsystem: subsystem, category: category.rawValue)
        if msg.isEmpty {
            os_signpost(type, log: log, name: name, signpostID: signpostID)
        } else {
            os_signpost(type, log: log, name: name, signpostID: signpostID, "%{public}s", msg)
        }
        return signpostID
    }
}
