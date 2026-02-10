//
//  JetEntitlementCache.swift
//  JetUI
//
//  订阅权益缓存模型 - 用于本地存储订阅状态
//

import Foundation

/// 订阅权益缓存
public struct JetEntitlementCache: Codable {
    /// 是否为 Pro 用户
    public let isPro: Bool
    
    /// 订阅过期时间
    public let expiration: Date?
    
    /// 产品 ID
    public let productId: String?
    
    /// 缓存更新时间
    public let updatedAt: Date
    
    public init(
        isPro: Bool,
        expiration: Date? = nil,
        productId: String? = nil,
        updatedAt: Date = Date()
    ) {
        self.isPro = isPro
        self.expiration = expiration
        self.productId = productId
        self.updatedAt = updatedAt
    }
    
    /// 检查缓存是否过期
    public var isExpired: Bool {
        if let expiration = expiration {
            return Date() > expiration
        }
        return false
    }
    
    /// 检查缓存是否有效（未过期且 isPro 为 true）
    public var isValid: Bool {
        return isPro && !isExpired
    }
}

// MARK: - Cache Manager

/// 权益缓存管理器
public enum JetEntitlementCacheManager {
    
    private static let cacheKey = "jet-entitlement-cache"
    
    /// 读取缓存的权益状态
    /// - Parameter accessGroup: Keychain 访问组
    /// - Returns: 缓存的权益信息
    public static func load(accessGroup: String? = nil) -> JetEntitlementCache? {
        try? JetKeychainStore.load(JetEntitlementCache.self, for: cacheKey, accessGroup: accessGroup)
    }
    
    /// 保存权益状态到缓存
    /// - Parameters:
    ///   - cache: 权益缓存
    ///   - accessGroup: Keychain 访问组
    public static func save(_ cache: JetEntitlementCache, accessGroup: String? = nil) {
        try? JetKeychainStore.save(cache, for: cacheKey, accessGroup: accessGroup)
    }
    
    /// 清除缓存（设置为非 Pro 状态）
    /// - Parameter accessGroup: Keychain 访问组
    public static func clear(accessGroup: String? = nil) {
        let cache = JetEntitlementCache(isPro: false, expiration: nil)
        try? JetKeychainStore.save(cache, for: cacheKey, accessGroup: accessGroup)
    }
    
    /// 删除缓存
    /// - Parameter accessGroup: Keychain 访问组
    public static func delete(accessGroup: String? = nil) {
        JetKeychainStore.delete(for: cacheKey, accessGroup: accessGroup)
    }
    
    /// 快速检查是否为 Pro（从缓存读取）
    /// - Parameter accessGroup: Keychain 访问组
    /// - Returns: 是否为 Pro
    public static func cachedIsPro(accessGroup: String? = nil) -> Bool {
        load(accessGroup: accessGroup)?.isValid ?? false
    }
}
