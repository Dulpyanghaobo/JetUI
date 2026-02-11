//
//  JetStoreService.swift
//  JetUI
//
//  StoreKit 2 服务层 - 处理订阅购买和权益验证
//

import Foundation
import StoreKit

// MARK: - Protocol

/// 订阅商店服务协议
public protocol JetStoreServiceProtocol {
    /// 获取所有可用产品
    func fetchProducts() async throws -> [Product]
    
    /// 购买产品
    func purchase(_ product: Product) async throws -> (Transaction, String)
    
    /// 恢复购买
    func restorePurchases() async throws
    
    /// 获取当前权益
    func currentEntitlements() async throws -> [Transaction]
    
    /// 检查是否有 Pro 权益
    func isEntitledToPro() async -> Bool
}

// MARK: - Error

/// 商店错误类型
public enum JetStoreError: Error, LocalizedError {
    case cancelled
    case pending
    case unknown
    case noProducts
    case purchaseFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .cancelled: return "Purchase was cancelled"
        case .pending: return "Purchase is pending"
        case .unknown: return "An unknown error occurred"
        case .noProducts: return "No products available"
        case .purchaseFailed(let reason): return "Purchase failed: \(reason)"
        }
    }
}

// MARK: - Implementation

/// StoreKit 2 商店服务实现
public final class JetStoreService: JetStoreServiceProtocol {
    
    private let signer: JetPromotionalOfferSigner?
    private let accountService: AccountServiceProtocol
    
    public init(
        signer: JetPromotionalOfferSigner? = nil,
        accountService: AccountServiceProtocol? = nil
    ) {
        self.signer = signer
        self.accountService = accountService ?? DefaultAccountService.shared
    }
    
    // MARK: - JetStoreServiceProtocol
    
    public func fetchProducts() async throws -> [Product] {
        guard let config = JetUI.subscriptionConfig else { return [] }
        
        guard !config.productIds.isEmpty else {
            throw JetStoreError.noProducts
        }
        return try await Product.products(for: config.productIds)
    }
    
    public func purchase(_ product: Product) async throws -> (Transaction, String) {
        let purchaseResult: Product.PurchaseResult
        
        // 检查是否有促销优惠
        if let offer = product.subscription?.promotionalOffers.first,
           let option = try? await signer?.purchaseOption(for: product, offer: offer) {
            purchaseResult = try await product.purchase(options: [option])
        } else {
            purchaseResult = try await product.purchase()
        }
        
        switch purchaseResult {
        case .success(let verification):
            let jws = verification.jwsRepresentation
            let transaction = try verification.payloadValue
            await transaction.finish()
            
            // 自动绑定到后端
            try await bindToBackend(jws: jws)
            
            return (transaction, jws)
            
        case .userCancelled:
            throw JetStoreError.cancelled
            
        case .pending:
            throw JetStoreError.pending
            
        @unknown default:
            throw JetStoreError.unknown
        }
    }
    
    // MARK: - Private Methods
    
    /// 绑定订阅到后端
    private func bindToBackend(jws: String) async throws {
        do {
            try await accountService.bindSubscription(
                signedPayLoad: jws,
                storeKitType: 2,
                usageType: 1
            )
            CSLogger.info("✅ Subscription bound to backend successfully", category: .subscription)
        } catch {
            CSLogger.error("❌ Failed to bind subscription: \(error.localizedDescription)", category: .subscription)
            // 不抛出错误，因为 StoreKit 购买已成功，后端绑定失败可以稍后重试
        }
    }
    
    public func restorePurchases() async throws {
        try await AppStore.sync()
    }
    
    public func currentEntitlements() async throws -> [Transaction] {
        var result = [Transaction]()
        for await verification in Transaction.currentEntitlements {
            if case .verified(let transaction) = verification,
               transaction.revocationDate == nil {
                result.append(transaction)
            }
        }
        return result
    }
    
    public func isEntitledToPro() async -> Bool {
        let entitlements = try? await currentEntitlements()
        
        guard let config = JetUI.subscriptionConfig else { return false }

        return entitlements?.contains(where: { config.proProductIds.contains($0.productID) }) ?? false
    }
}

// MARK: - Promotional Offer Signer

/// 促销优惠签名协议
public protocol JetPromotionalOfferSigner {
    func purchaseOption(for product: Product, offer: Product.SubscriptionOffer) async throws -> Product.PurchaseOption
}
