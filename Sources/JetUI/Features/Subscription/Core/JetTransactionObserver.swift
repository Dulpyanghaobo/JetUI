//
//  JetTransactionObserver.swift
//  JetUI
//
//  交易观察器 - 监听 StoreKit 交易更新并自动更新缓存
//

import Foundation
import StoreKit

/// 交易观察器 - 监听 StoreKit 交易并更新本地缓存
public final class JetTransactionObserver {
    
    // MARK: - Properties
    
    private let storeService: JetStoreServiceProtocol
    private let config: JetSubscriptionConfig
    private let accessGroup: String?
    private var observerTask: Task<Void, Never>?
    
    /// 权益变更通知名
    public static let entitlementChangedNotification = Notification.Name("JetProEntitlementChanged")
    
    // MARK: - Initialization
    
    public init(
        storeService: JetStoreServiceProtocol,
        config: JetSubscriptionConfig,
        accessGroup: String? = nil
    ) {
        self.storeService = storeService
        self.config = config
        self.accessGroup = accessGroup
    }
    
    deinit {
        stopObserving()
    }
    
    // MARK: - Public Methods
    
    /// 开始监听交易更新
    public func startObserving() {
        observerTask?.cancel()
        observerTask = Task.detached(priority: .background) { [weak self] in
            guard let self = self else { return }
            
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    // 更新本地缓存
                    await self.handleVerifiedTransaction(transaction)
                    
                    // 完成交易
                    await transaction.finish()
                    
                    // 发送通知
                    await MainActor.run {
                        NotificationCenter.default.post(
                            name: JetTransactionObserver.entitlementChangedNotification,
                            object: nil
                        )
                    }
                    
                case .unverified(let transaction, let error):
                    CSLogger.warning(
                        "⚠️ Unverified transaction: \(transaction.id), error: \(error.localizedDescription)",
                        category: .subscription
                    )
                }
            }
        }
    }
    
    /// 停止监听
    public func stopObserving() {
        observerTask?.cancel()
        observerTask = nil
    }
    
    /// 刷新权益缓存
    @discardableResult
    public func refreshEntitlementCache() async -> Bool {
        do {
            let entitlements = try await storeService.currentEntitlements()
            
            // 找到属于 proProductIds 的有效交易
            if let proTransaction = entitlements.first(where: { config.proProductIds.contains($0.productID) }) {
                let cache = JetEntitlementCache(
                    isPro: true,
                    expiration: proTransaction.expirationDate,
                    productId: proTransaction.productID
                )
                JetEntitlementCacheManager.save(cache, accessGroup: accessGroup)
                return true
            } else {
                // 没有 Pro 订阅
                JetEntitlementCacheManager.clear(accessGroup: accessGroup)
                return false
            }
        } catch {
            CSLogger.error("Failed to refresh entitlement cache: \(error.localizedDescription)", category: .subscription)
            JetEntitlementCacheManager.clear(accessGroup: accessGroup)
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func handleVerifiedTransaction(_ transaction: Transaction) async {
        let isPro = config.proProductIds.contains(transaction.productID)
        let cache = JetEntitlementCache(
            isPro: isPro,
            expiration: transaction.expirationDate,
            productId: transaction.productID
        )
        JetEntitlementCacheManager.save(cache, accessGroup: accessGroup)
    }
}

// MARK: - IAP Bootstrap Helper

/// IAP 启动配置助手
public struct JetIAPBootstrap {
    
    public let config: JetSubscriptionConfig
    public let accessGroup: String?
    public let storeService: JetStoreServiceProtocol
    public let transactionObserver: JetTransactionObserver
    
    public init(config: JetSubscriptionConfig, accessGroup: String? = nil) {
        self.config = config
        self.accessGroup = accessGroup
        self.storeService = JetStoreService(config: config)
        self.transactionObserver = JetTransactionObserver(
            storeService: storeService,
            config: config,
            accessGroup: accessGroup
        )
    }
    
    /// 启动时快速读取缓存的 Pro 状态
    public func cachedIsPro() -> Bool {
        JetEntitlementCacheManager.cachedIsPro(accessGroup: accessGroup)
    }
    
    /// 刷新权益缓存
    @discardableResult
    public func refreshEntitlementCache() async -> Bool {
        await transactionObserver.refreshEntitlementCache()
    }
    
    /// 当前是否为 Pro
    public func isPro() -> Bool {
        cachedIsPro()
    }
    
    /// 启动监听 + 刷新缓存
    public func start() {
        transactionObserver.startObserving()
        Task {
            await refreshEntitlementCache()
        }
    }
    
    /// 停止监听
    public func stop() {
        transactionObserver.stopObserving()
    }
}
