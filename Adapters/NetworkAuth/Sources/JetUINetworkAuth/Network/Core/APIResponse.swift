//
//  APIResponse.swift
//  JetUI
//
//  标准 API 响应模型
//

import Foundation

/// 标准 API 响应结构
public struct APIResponse<T: Decodable>: Decodable {
    public let code: Int
    public let message: String?
    public let data: T?
    
    public init(code: Int, message: String? = nil, data: T? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}

/// 用于解码 `{}` 或 `[]` 类型的 data 字段
public struct AnyDecodable: Decodable {
    public let value: Any

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(Bool.self) {
            self.value = value
        } else if let value = try? container.decode(Int.self) {
            self.value = value
        } else if let value = try? container.decode(Double.self) {
            self.value = value
        } else if let value = try? container.decode(String.self) {
            self.value = value
        } else if let value = try? container.decode([String: AnyDecodable].self) {
            self.value = value.mapValues { $0.value }
        } else if let value = try? container.decode([AnyDecodable].self) {
            self.value = value.map { $0.value }
        } else {
            self.value = NSNull()
        }
    }
}

// MARK: - KeyedDecodingContainer Extension

public extension KeyedDecodingContainer {
    /// 返回可选值；若 key 不存在或为 null，则直接返回 nil
    func decodeLossyIfPresent<T: Decodable>(_ type: T.Type,
                                            forKey key: Key) throws -> T? {
        // 1) key 不存在
        guard contains(key) else { return nil }

        // 2) 显式 null
        if try decodeNil(forKey: key) { return nil }

        // 3) 尝试常规解码；失败再做宽容处理
        do {
            return try decode(T.self, forKey: key)
        } catch {
            // 3‑1) 如果期望 Int/Bool，却收到 "" / "0" / "1" / "true"
            if let str = try? decode(String.self, forKey: key),
               let converted = Self.convert(string: str, to: T.self) {
                return converted
            }
            // 3‑2) 其他情况，让上层决定是否抛错或忽略
            throw error
        }
    }

    private static func convert<T>(string: String, to _: T.Type) -> T? {
        switch T.self {
        case is Int32.Type, is Int.Type:
            return Int32(string).map { $0 as! T }
        case is Bool.Type:
            return Bool(string).map { $0 as! T }
        default: return nil
        }
    }
}