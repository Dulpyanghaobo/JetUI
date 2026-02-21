//
//  JetPaywallViewModel.swift
//  JetUI
//
//  Paywall 视图模型 - 管理订阅页面状态和购买逻辑
//

import SwiftUI
import StoreKit
import Combine

// MARK: - Plan Display Model

/// 订阅计划显示模型
public struct JetPlanDisplay: Identifiable {
    public let id: String
    public let product: Product
    public let title: String
    public let priceText: String
    public let sublineText: String?
    public let trialBadge: String?
    public let promoBadge: String?
    public let isYearly: Bool
    public let isWeekly: Bool
    
    public init(
        product: Product,
        title: String? = nil,
        sublineText: String? = nil,
        trialBadge: String? = nil,
        promoBadge: String? = nil
    ) {
        self.id = product.id
        self.product = product
        self.priceText = product.displayPrice
        
        // 自动生成标题
        if let customTitle = title {
            self.title = customTitle
        } else if let period = product.subscription?.subscriptionPeriod {
            switch period.unit {
            case .year: self.title = SubL.Period.yearly
            case .month: self.title = period.value == 1 ? SubL.Period.monthly : SubL.Period.months(period.value)
            case .week: self.title = SubL.Period.weekly
            case .day: self.title = period.value == 7 ? SubL.Period.weekly : SubL.Period.days(period.value)
            @unknown default: self.title = product.displayName
            }
        } else {
            self.title = product.displayName
        }
        
        self.sublineText = sublineText
        self.trialBadge = trialBadge
        self.promoBadge = promoBadge
        
        // 判断周期类型
        if let period = product.subscription?.subscriptionPeriod {
            self.isYearly = period.unit == .year
            self.isWeekly = period.unit == .week || (period.unit == .day && period.value == 7)
        } else {
            self.isYearly = false
            self.isWeekly = false
        }
    }
}

// MARK: - Paywall ViewModel

/// Paywall 视图模型
@MainActor
public final class JetPaywallViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 订阅计划列表
    @Published public private(set) var plans: [JetPlanDisplay] = []
    
    /// 当前选中的产品 ID
    @Published public var selectedProductID: String?
    
    /// 是否正在加载
    @Published public private(set) var isLoading = false
    
    /// 正在购买的产品 ID
    @Published public private(set) var purchaseInProgress: String?
    
    /// 恢复购买进行中
    @Published public private(set) var restoreInProgress = false
    
    /// 是否应该关闭 Paywall
    @Published public private(set) var shouldDismissPaywall = false
    
    /// 错误信息
    @Published public var errorMessage: String?
    
    /// 续订提示文本
    @Published public private(set) var nextRenewalHint: String?
    
    // MARK: - Private Properties
    
    private let storeService: JetStoreServiceProtocol

    public init(storeService: JetStoreServiceProtocol? = nil) {
        
        self.storeService = storeService ?? JetStoreService()
        
        Task { @MainActor in
            await load()
        }
    }
    
    // MARK: - Public Methods
    
    /// 加载产品列表
    public func load() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let products = try await storeService.fetchProducts()
            
            // 转换为显示模型
            var displayPlans: [JetPlanDisplay] = []
            for product in products {
                let plan = createPlanDisplay(from: product)
                displayPlans.append(plan)
            }
            
            // 按价格排序（高到低，年费优先）
            plans = displayPlans.sorted { p1, p2 in
                if p1.isYearly != p2.isYearly { return p1.isYearly }
                return p1.product.price > p2.product.price
            }
            
            // 默认选中年费计划
            if selectedProductID == nil {
                selectedProductID = plans.first(where: { $0.isYearly })?.id ?? plans.first?.id
            }
            
            isLoading = false
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    /// 购买选中的产品
    public func purchaseSelected() async {
        guard let productID = selectedProductID,
              let plan = plans.first(where: { $0.id == productID }) else {
            return
        }
        
        await purchase(plan.product)
    }
    
    /// 购买指定产品
    public func purchase(_ product: Product) async {
        guard purchaseInProgress == nil else { return }
        
        purchaseInProgress = product.id
        AnalyticsManager.logPurchaseStart(productId: product.id)
        
        do {
            let (_, _) = try await storeService.purchase(product)
            
            // 购买成功（如果执行到这里说明没有抛出异常）
            AnalyticsManager.logPurchaseSuccess(productId: product.id)
            shouldDismissPaywall = true
            
            purchaseInProgress = nil
            
        } catch JetStoreError.cancelled {
            purchaseInProgress = nil
            AnalyticsManager.logPurchaseCancelled(productId: product.id)
            
        } catch {
            purchaseInProgress = nil
            errorMessage = error.localizedDescription
            AnalyticsManager.logPurchaseFailed(productId: product.id, error: error.localizedDescription)
        }
    }
    
    /// 恢复购买
    public func restore() async {
        guard !restoreInProgress else { return }
        
        restoreInProgress = true
        AnalyticsManager.logEvent(JetPaywallEvent.restoreStart)
        
        do {
            try await storeService.restorePurchases()
            
            let isPro = await storeService.isEntitledToPro()
            if isPro {
                AnalyticsManager.logRestoreSuccess()
                shouldDismissPaywall = true
            } else {
                errorMessage = SubL.Error.noActiveSubscription
                AnalyticsManager.logEvent(JetPaywallEvent.restoreNoSubscription)
            }
            
            restoreInProgress = false
            
        } catch {
            restoreInProgress = false
            errorMessage = error.localizedDescription
            AnalyticsManager.logRestoreFailed(error: error.localizedDescription)
        }
    }
    
    // MARK: - Private Methods
    
    private func createPlanDisplay(from product: Product) -> JetPlanDisplay {
        var subline: String? = nil
        var trialBadge: String? = nil
        
        // 检查是否有免费试用
        if let intro = product.subscription?.introductoryOffer,
           intro.paymentMode == .freeTrial {
            let period = intro.period
            let trialDays: String
            switch period.unit {
            case .day: trialDays = SubL.Period.days(period.value)
            case .week: trialDays = SubL.Period.days(period.value * 7)
            case .month: trialDays = SubL.Period.months(period.value)
            case .year: trialDays = SubL.Period.years(period.value)
            @unknown default: trialDays = ""
            }
            trialBadge = SubL.Trial.freeTrial(trialDays)
            subline = SubL.Trial.freeThenPrice(trialDays, product.displayPrice)
        }
        
        // 生成续订说明
        if subline == nil, let period = product.subscription?.subscriptionPeriod {
            switch period.unit {
            case .year: subline = "\(product.displayPrice)/year"
            case .month: subline = "\(product.displayPrice)/month"
            case .week: subline = "\(product.displayPrice)/week"
            case .day: subline = "\(product.displayPrice)/\(period.value) days"
            @unknown default: break
            }
        }
        
        return JetPlanDisplay(
            product: product,
            sublineText: subline,
            trialBadge: trialBadge
        )
    }
    
    /// 计算节省百分比
    public func calculateSavePercentage(for plan: JetPlanDisplay) -> Int? {
        guard plan.isYearly else { return nil }
        
        // 找到周订阅作为基准
        guard let weeklyPlan = plans.first(where: { $0.isWeekly }) else {
            return nil
        }
        
        let weeklyPrice = weeklyPlan.product.price
        let currentPrice = plan.product.price
        
        // 计算年订阅的等效周价格
        guard let period = plan.product.subscription?.subscriptionPeriod else { return nil }
        
        let equivalentWeeklyPrice: Decimal
        switch period.unit {
        case .year:
            equivalentWeeklyPrice = currentPrice / Decimal(52)
        case .month:
            equivalentWeeklyPrice = currentPrice / Decimal(4)
        default:
            return nil
        }
        
        guard weeklyPrice > 0 else { return nil }
        
        let saveAmount = weeklyPrice - equivalentWeeklyPrice
        let savePercentage = (saveAmount / weeklyPrice) * 100
        let percent = Int(NSDecimalNumber(decimal: savePercentage).doubleValue.rounded())
        
        return percent > 0 ? percent : nil
    }
}

