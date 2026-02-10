//
//  JetSubscriptionManager.swift
//  JetUI
//
//  订阅管理器 - 管理订阅状态和权益
//

import Foundation
import StoreKit
import Combine

/// 订阅管理器 - 管理订阅状态和权益
@MainActor
public final class JetSubscriptionManager: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 是否为 Pro 用户
    @Published public private(set) var isPro: Bool = false
    
    /// 可用产品列表
    @Published public private(set) var products: [Product] = []
    
    /// 是否正在加载
    @Published public private(set) var isLoading: Bool = false
    
    /// 错误信息
    @Published public var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let storeService: JetStoreServiceProtocol
    private let config: JetSubscriptionConfig
    private var transactionTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    public init(config: JetSubscriptionConfig, storeService: JetStoreServiceProtocol? = nil) {
        self.config = config
        self.storeService = storeService ?? JetStoreService(config: config)
        
        // 启动交易监听
        startTransactionListener()
    }
    
    deinit {
        transactionTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// 加载产品和权益状态
    public func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 并发加载产品和权益
            async let productsTask = storeService.fetchProducts()
            async let entitledTask = storeService.isEntitledToPro()
            
            let (fetchedProducts, isEntitled) = try await (productsTask, entitledTask)
            
            self.products = fetchedProducts.sorted { $0.price < $1.price }
            self.isPro = isEntitled
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    /// 购买产品
    public func purchase(_ product: Product) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (_, _) = try await storeService.purchase(product)
            isPro = await storeService.isEntitledToPro()
            return isPro
        } catch JetStoreError.cancelled {
            // 用户取消，不显示错误
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// 恢复购买
    public func restore() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await storeService.restorePurchases()
            isPro = await storeService.isEntitledToPro()
            return isPro
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// 刷新权益状态
    public func refreshEntitlements() async {
        isPro = await storeService.isEntitledToPro()
    }
    
    // MARK: - Private Methods
    
    private func startTransactionListener() {
        transactionTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
    }
}

// MARK: - Convenience Extensions

extension Product {
    /// 格式化价格显示
    public var formattedPrice: String {
        displayPrice
    }
    
    /// 订阅周期描述
    public var subscriptionPeriodDescription: String? {
        guard let period = subscription?.subscriptionPeriod else { return nil }
        
        switch period.unit {
        case .day:
            return period.value == 1 ? "Daily" : "\(period.value) Days"
        case .week:
            return period.value == 1 ? "Weekly" : "\(period.value) Weeks"
        case .month:
            return period.value == 1 ? "Monthly" : "\(period.value) Months"
        case .year:
            return period.value == 1 ? "Yearly" : "\(period.value) Years"
        @unknown default:
            return nil
        }
    }
    
    /// 是否有免费试用
    public var hasFreeTrial: Bool {
        subscription?.introductoryOffer?.paymentMode == .freeTrial
    }
    
    /// 试用期描述
    public var trialPeriodDescription: String? {
        guard let offer = subscription?.introductoryOffer,
              offer.paymentMode == .freeTrial else { return nil }
        
        let period = offer.period
        switch period.unit {
        case .day:
            return "\(period.value) Day Free Trial"
        case .week:
            return "\(period.value) Week Free Trial"
        case .month:
            return "\(period.value) Month Free Trial"
        case .year:
            return "\(period.value) Year Free Trial"
        @unknown default:
            return nil
        }
    }
}
