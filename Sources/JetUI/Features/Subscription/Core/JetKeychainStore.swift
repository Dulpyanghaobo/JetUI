//
//  JetKeychainStore.swift
//  JetUI
//
//  Keychain 安全存储工具 - 用于存储订阅权益缓存
//

import Foundation
import Security

/// Keychain 存储工具
public enum JetKeychainStore {
    
    // MARK: - Public Methods
    
    /// 保存 Codable 值到 Keychain
    /// - Parameters:
    ///   - value: 要保存的值
    ///   - key: 存储键
    ///   - accessGroup: 访问组（用于跨 App 共享）
    public static func save<Value: Codable>(
        _ value: Value,
        for key: String,
        accessGroup: String? = nil
    ) throws {
        let data = try JSONEncoder().encode(value)
        var query = baseQuery(key, accessGroup)
        query[kSecValueData as String] = data
        
        // 删除旧值后添加新值
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw JetKeychainError.unhandled(status)
        }
    }
    
    /// 从 Keychain 加载 Codable 值
    /// - Parameters:
    ///   - type: 值类型
    ///   - key: 存储键
    ///   - accessGroup: 访问组
    /// - Returns: 存储的值，如果不存在则返回 nil
    public static func load<Value: Codable>(
        _ type: Value.Type,
        for key: String,
        accessGroup: String? = nil
    ) throws -> Value? {
        var query = baseQuery(key, accessGroup)
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess, let data = result as? Data else {
            throw JetKeychainError.unhandled(status)
        }
        
        return try JSONDecoder().decode(Value.self, from: data)
    }
    
    /// 删除 Keychain 中的值
    /// - Parameters:
    ///   - key: 存储键
    ///   - accessGroup: 访问组
    public static func delete(
        for key: String,
        accessGroup: String? = nil
    ) {
        let query = baseQuery(key, accessGroup)
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Private Methods
    
    private static func baseQuery(_ key: String, _ group: String?) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.jetui.subscription",
            kSecAttrAccount as String: key,
        ]
        if let group = group, !group.isEmpty {
            query[kSecAttrAccessGroup as String] = group
        }
        return query
    }
}

// MARK: - Error

/// Keychain 错误类型
public enum JetKeychainError: Error, LocalizedError {
    case unhandled(OSStatus)
    
    public var errorDescription: String? {
        switch self {
        case .unhandled(let status):
            return "Keychain error: \(status)"
        }
    }
}
