//
//  JetAnalyticsEventDefinition.swift
//  JetUI
//
//  Typed event definitions keep platform/module/product analytics separated.
//

import Foundation

public enum JetAnalyticsScope: String, Equatable {
    case platform
    case settings
    case subscription
    case product
}

public enum JetSubscriptionAnalyticsEvent: String, Equatable {
    case view = "paywall_view"
    case action = "paywall_action"
    case optionSelect = "paywall_option_select"
    case purchaseStart = "purchase_start"
    case purchaseSuccess = "purchase_success"
    case purchaseCancelled = "purchase_cancelled"
    case purchaseFailed = "purchase_failure"
    case restore = "restore_purchase"
    case entitlementRefresh = "entitlement_refresh"
}

public enum JetSettingsAnalyticsEvent: String, Equatable {
    case view = "settings_view"
    case action = "settings_action"
}

public struct JetAnalyticsEventDefinition: Equatable {
    public let name: String
    public let scope: JetAnalyticsScope

    public init(name: String, scope: JetAnalyticsScope) {
        self.name = name
        self.scope = scope
    }

    public static let appOpen = JetAnalyticsEventDefinition(name: "app_open", scope: .platform)

    public static func screenView(_: String) -> JetAnalyticsEventDefinition {
        JetAnalyticsEventDefinition(name: "screen_view", scope: .platform)
    }

    public static func settings(_ event: JetSettingsAnalyticsEvent) -> JetAnalyticsEventDefinition {
        JetAnalyticsEventDefinition(name: event.rawValue, scope: .settings)
    }

    public static func subscription(_ event: JetSubscriptionAnalyticsEvent) -> JetAnalyticsEventDefinition {
        JetAnalyticsEventDefinition(name: event.rawValue, scope: .subscription)
    }

    public static func product(_ name: String) -> JetAnalyticsEventDefinition {
        JetAnalyticsEventDefinition(name: name, scope: .product)
    }
}
