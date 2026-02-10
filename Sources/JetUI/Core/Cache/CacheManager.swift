//
//  CacheManager.swift
//  JetUI
//
//  Generic cache manager with TTL support
//  Supports both in-memory and UserDefaults persistence
//
//  Migrated from TimeProof/App/CacheManager.swift
//

import Foundation

/// Generic cache manager with time-to-live (TTL) support
@MainActor
public class CacheManager {
    
    // MARK: - Singleton
    
    public static let shared = CacheManager()
    
    // MARK: - Private Properties
    
    private var memoryCache: [String: CacheEntry] = [:]
    private let lock = NSLock()
    private var cleanupTimer: Timer?
    
    /// Optional logger for debugging
    public var logger: ((String) -> Void)?
    
    // MARK: - Initialization
    
    private init() {
        // Schedule periodic cleanup every 5 minutes to prevent unbounded growth
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.cleanupExpiredEntries()
            }
        }
        
        log("✅ [CacheManager] Initialized with periodic cleanup (every 5 min)")
    }
    
    deinit {
        cleanupTimer?.invalidate()
    }
    
    // MARK: - Cache Entry
    
    private struct CacheEntry {
        let data: Data
        let expirationDate: Date
        
        var isExpired: Bool {
            return Date() > expirationDate
        }
    }
    
    // MARK: - Private Logging
    
    private func log(_ message: String) {
        logger?(message)
        #if DEBUG
        print(message)
        #endif
    }
    
    // MARK: - Public Methods
    
    /// Set cache with TTL
    /// - Parameters:
    ///   - key: Cache key
    ///   - value: Value to cache (must be Codable)
    ///   - ttl: Time to live in seconds (default: 15 minutes)
    ///   - persistent: Whether to persist to UserDefaults (default: false, memory only)
    public func set<T: Codable>(
        key: String,
        value: T,
        ttl: TimeInterval = 15 * 60,
        persistent: Bool = false
    ) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let data = try? JSONEncoder().encode(value) else {
            log("⚠️ [CacheManager] Failed to encode value for key: \(key)")
            return
        }
        
        let expirationDate = Date().addingTimeInterval(ttl)
        let entry = CacheEntry(data: data, expirationDate: expirationDate)
        
        // Store in memory
        memoryCache[key] = entry
        
        // Store in UserDefaults if persistent
        if persistent {
            let persistentKey = "cache_\(key)"
            let expirationKey = "cache_expiration_\(key)"
            UserDefaults.standard.set(data, forKey: persistentKey)
            UserDefaults.standard.set(expirationDate.timeIntervalSince1970, forKey: expirationKey)
        }
        
        log("✅ [CacheManager] Cached '\(key)' with TTL: \(ttl)s, persistent: \(persistent)")
    }
    
    /// Get cached value
    /// - Parameters:
    ///   - key: Cache key
    ///   - type: Type to decode to
    ///   - persistent: Whether to check UserDefaults for persistent cache
    /// - Returns: Cached value if exists and not expired, nil otherwise
    public func get<T: Codable>(
        key: String,
        as type: T.Type,
        persistent: Bool = false
    ) -> T? {
        lock.lock()
        defer { lock.unlock() }
        
        // Check memory cache first
        if let entry = memoryCache[key] {
            if entry.isExpired {
                log("⏰ [CacheManager] Memory cache expired for key: \(key)")
                memoryCache.removeValue(forKey: key)
            } else {
                if let value = try? JSONDecoder().decode(T.self, from: entry.data) {
                    log("✅ [CacheManager] Memory cache hit for key: \(key)")
                    return value
                }
            }
        }
        
        // Check persistent cache if enabled
        if persistent {
            let persistentKey = "cache_\(key)"
            let expirationKey = "cache_expiration_\(key)"
            
            if let data = UserDefaults.standard.data(forKey: persistentKey),
               let expirationTimestamp = UserDefaults.standard.object(forKey: expirationKey) as? TimeInterval {
                
                let expirationDate = Date(timeIntervalSince1970: expirationTimestamp)
                
                if Date() > expirationDate {
                    log("⏰ [CacheManager] Persistent cache expired for key: \(key)")
                    UserDefaults.standard.removeObject(forKey: persistentKey)
                    UserDefaults.standard.removeObject(forKey: expirationKey)
                } else {
                    if let value = try? JSONDecoder().decode(T.self, from: data) {
                        log("✅ [CacheManager] Persistent cache hit for key: \(key)")
                        // Restore to memory cache
                        memoryCache[key] = CacheEntry(data: data, expirationDate: expirationDate)
                        return value
                    }
                }
            }
        }
        
        log("❌ [CacheManager] Cache miss for key: \(key)")
        return nil
    }
    
    /// Check if cache exists and is valid
    public func has(key: String, persistent: Bool = false) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        // Check memory cache
        if let entry = memoryCache[key], !entry.isExpired {
            return true
        }
        
        // Check persistent cache
        if persistent {
            let expirationKey = "cache_expiration_\(key)"
            if let expirationTimestamp = UserDefaults.standard.object(forKey: expirationKey) as? TimeInterval {
                let expirationDate = Date(timeIntervalSince1970: expirationTimestamp)
                return Date() <= expirationDate
            }
        }
        
        return false
    }
    
    /// Remove cache for specific key
    public func remove(key: String, persistent: Bool = false) {
        lock.lock()
        defer { lock.unlock() }
        
        memoryCache.removeValue(forKey: key)
        
        if persistent {
            let persistentKey = "cache_\(key)"
            let expirationKey = "cache_expiration_\(key)"
            UserDefaults.standard.removeObject(forKey: persistentKey)
            UserDefaults.standard.removeObject(forKey: expirationKey)
        }
        
        log("🗑️ [CacheManager] Removed cache for key: \(key)")
    }
    
    /// Clear all caches
    public func clearAll(includePersistent: Bool = false) {
        lock.lock()
        defer { lock.unlock() }
        
        memoryCache.removeAll()
        
        if includePersistent {
            let defaults = UserDefaults.standard
            let keys = defaults.dictionaryRepresentation().keys
            for key in keys where key.hasPrefix("cache_") {
                defaults.removeObject(forKey: key)
            }
        }
        
        log("🗑️ [CacheManager] Cleared all caches, persistent: \(includePersistent)")
    }
    
    /// Cleanup expired entries (called periodically)
    private func cleanupExpiredEntries() {
        lock.lock()
        let beforeCount = memoryCache.count
        memoryCache = memoryCache.filter { !$0.value.isExpired }
        let afterCount = memoryCache.count
        lock.unlock()
        
        if beforeCount > afterCount {
            log("🧹 [CacheManager] Cleaned up \(beforeCount - afterCount) expired entries, remaining: \(afterCount)")
        }
    }
    
    /// Get remaining TTL for a cache key (in seconds)
    public func remainingTTL(key: String, persistent: Bool = false) -> TimeInterval? {
        lock.lock()
        defer { lock.unlock() }
        
        // Check memory cache
        if let entry = memoryCache[key] {
            let remaining = entry.expirationDate.timeIntervalSinceNow
            return remaining > 0 ? remaining : nil
        }
        
        // Check persistent cache
        if persistent {
            let expirationKey = "cache_expiration_\(key)"
            if let expirationTimestamp = UserDefaults.standard.object(forKey: expirationKey) as? TimeInterval {
                let expirationDate = Date(timeIntervalSince1970: expirationTimestamp)
                let remaining = expirationDate.timeIntervalSinceNow
                return remaining > 0 ? remaining : nil
            }
        }
        
        return nil
    }
    
    /// Get current cache statistics
    public func statistics() -> CacheStatistics {
        lock.lock()
        defer { lock.unlock() }
        
        let validEntries = memoryCache.filter { !$0.value.isExpired }
        let expiredEntries = memoryCache.filter { $0.value.isExpired }
        
        return CacheStatistics(
            totalEntries: memoryCache.count,
            validEntries: validEntries.count,
            expiredEntries: expiredEntries.count,
            memorySizeBytes: memoryCache.values.reduce(0) { $0 + $1.data.count }
        )
    }
}

// MARK: - Supporting Types

/// Cache statistics
public struct CacheStatistics {
    public let totalEntries: Int
    public let validEntries: Int
    public let expiredEntries: Int
    public let memorySizeBytes: Int
    
    public var memorySizeKB: Double {
        Double(memorySizeBytes) / 1024.0
    }
    
    public var memorySizeMB: Double {
        Double(memorySizeBytes) / 1024.0 / 1024.0
    }
}