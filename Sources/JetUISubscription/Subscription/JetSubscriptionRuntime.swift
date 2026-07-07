//
//  JetSubscriptionRuntime.swift
//  JetUI
//
//  订阅模块运行时装配 - 将配置、商店服务和状态管理器收束到同一入口
//

import Foundation

@MainActor
public final class JetSubscriptionRuntime {
    public let config: JetSubscriptionConfig
    public let storeService: JetStoreServiceProtocol
    public let manager: JetSubscriptionManager

    public init(
        config: JetSubscriptionConfig,
        storeService: JetStoreServiceProtocol? = nil
    ) {
        self.config = config
        let resolvedStoreService = storeService ?? JetStoreService(config: config)
        self.storeService = resolvedStoreService
        self.manager = JetSubscriptionManager(storeService: resolvedStoreService)
    }

    public func makePaywallViewModel(source: String = "unknown") -> JetPaywallViewModel {
        JetPaywallViewModel(storeService: storeService, paywallSource: source)
    }
}
