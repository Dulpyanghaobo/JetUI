//
//  JetPaywallRecoveryState.swift
//  JetUI
//
//  Recovery and analytics-safe failure classification for Paywall operations.
//

import Foundation
import StoreKit
import JetUIAnalytics

public extension JetPaywallFailureCategory {
    static func category(for storeError: JetStoreError) -> JetPaywallFailureCategory {
        switch storeError {
        case .cancelled:
            return .userCancelled
        case .pending:
            return .pending
        case .noProducts:
            return .configuration
        case .purchaseFailed(let reason):
            return category(for: NSError(domain: "JetStoreError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: reason
            ]))
        case .unknown:
            return .unknown
        }
    }

    static func subscriptionCategory(for error: Error) -> JetPaywallFailureCategory {
        if let storeError = error as? JetStoreError {
            return category(for: storeError)
        }
        return category(for: error)
    }
}

public struct JetPaywallRecoveryState: Equatable {
    public let title: String
    public let message: String
    public let retryTitle: String
    public let restoreTitle: String
    public let reasonCategory: String

    public init?(error: Error) {
        let category = JetPaywallFailureCategory.subscriptionCategory(for: error)
        self.init(category: category)
    }

    public init?(category: JetPaywallFailureCategory) {
        guard category.isRecoverable else { return nil }

        self.reasonCategory = category.rawValue
        self.retryTitle = SubL.Button.retry
        self.restoreTitle = SubL.Button.restore

        switch category {
        case .pending:
            self.title = SubL.Error.purchasePendingTitle
            self.message = SubL.Error.purchasePendingRecovery
        case .network:
            self.title = SubL.Error.purchaseRecoveryTitle
            self.message = SubL.Error.purchaseNetworkRecovery
        case .storeUnavailable:
            self.title = SubL.Error.purchaseRecoveryTitle
            self.message = SubL.Error.purchaseStoreRecovery
        case .configuration:
            self.title = SubL.Error.purchaseRecoveryTitle
            self.message = SubL.Error.purchaseConfigurationRecovery
        case .notEntitled, .unknown:
            self.title = SubL.Error.purchaseRecoveryTitle
            self.message = SubL.Error.purchaseGenericRecovery
        case .userCancelled:
            return nil
        }
    }
}
