//
//  JetSubscriptionConfig.swift
//  JetUI
//
//  订阅配置模型 - 定义 App 的订阅产品和权益
//

import Foundation

/// 订阅配置
public struct JetSubscriptionConfig {
    /// 所有可用的产品 ID（用于 fetchProducts）
    public let productIds: [String]
    
    /// Pro 权益的产品 ID 集合
    public let proProductIds: Set<String>
    
    /// 订阅组标识
    public let groupId: String
    
    /// 当前 App 的标识符
    public let appIdentifier: String
    
    /// 是否支持家庭共享
    public let familySharingEnabled: Bool
    
    /// 是否支持试用期
    public let trialSupported: Bool
    
    /// 每个产品的订阅层级（用于升级/降级策略）
    public let tierLevel: [String: Int]
    
    /// 本地化的权益描述
    public let localizedBenefits: String
    
    public init(
        productIds: [String],
        proProductIds: Set<String>,
        groupId: String,
        appIdentifier: String,
        familySharingEnabled: Bool = true,
        trialSupported: Bool = true,
        tierLevel: [String: Int] = [:],
        localizedBenefits: String = ""
    ) {
        self.productIds = productIds
        self.proProductIds = proProductIds
        self.groupId = groupId
        self.appIdentifier = appIdentifier
        self.familySharingEnabled = familySharingEnabled
        self.trialSupported = trialSupported
        self.tierLevel = tierLevel
        self.localizedBenefits = localizedBenefits
    }
}

// MARK: - Presets

extension JetSubscriptionConfig {
    public static var empty: JetSubscriptionConfig {
        JetSubscriptionConfig(
            productIds: [
                "com.timeproof.pro.weekly",
                "com.timeproof.pro.monthly",
                "com.timeproof.pro.yearly",
                "com.timeproof.pro.lifetime"
            ],
            proProductIds: [
                "com.timeproof.pro.weekly",
                "com.timeproof.pro.monthly",
                "com.timeproof.pro.yearly",
                "com.timeproof.pro.lifetime"
            ],
            groupId: "21473817",
            appIdentifier: "com.timeproof.app"
        )
    }
}
