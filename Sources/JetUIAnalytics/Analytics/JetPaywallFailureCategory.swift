//
//  JetPaywallFailureCategory.swift
//  JetUI
//
//  Analytics-safe failure classification for paywall operations.
//

import Foundation
import StoreKit

public enum JetPaywallFailureCategory: String, Equatable {
    case userCancelled = "user_cancelled"
    case pending
    case network
    case storeUnavailable = "store_unavailable"
    case notEntitled = "not_entitled"
    case configuration
    case unknown

    public var isRecoverable: Bool {
        switch self {
        case .userCancelled:
            return false
        case .pending, .network, .storeUnavailable, .notEntitled, .configuration, .unknown:
            return true
        }
    }

    public static func category(for error: Error) -> JetPaywallFailureCategory {
        if let storeKitError = error as? StoreKitError {
            switch storeKitError {
            case .userCancelled:
                return .userCancelled
            case .networkError:
                return .network
            case .notAvailableInStorefront:
                return .storeUnavailable
            case .notEntitled:
                return .notEntitled
            case .unsupported:
                return .configuration
            case .systemError(let underlying):
                return category(for: underlying)
            case .unknown:
                return .unknown
            @unknown default:
                return .unknown
            }
        }

        if let skError = error as? SKError {
            return category(forStoreKitCode: skError.code)
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        if nsError.domain == SKErrorDomain,
           let code = SKError.Code(rawValue: nsError.code) {
            return category(forStoreKitCode: code)
        }

        return category(forMessage: error.localizedDescription)
    }

    private static func category(forStoreKitCode code: SKError.Code) -> JetPaywallFailureCategory {
        switch code {
        case .paymentCancelled:
            return .userCancelled
        case .cloudServiceNetworkConnectionFailed:
            return .network
        case .storeProductNotAvailable, .paymentNotAllowed, .clientInvalid:
            return .storeUnavailable
        default:
            return .unknown
        }
    }

    private static func category(forMessage message: String) -> JetPaywallFailureCategory {
        let description = message.lowercased()
        if description.contains("cancel") { return .userCancelled }
        if description.contains("network") || description.contains("internet") || description.contains("offline") {
            return .network
        }
        if description.contains("storefront") || description.contains("store unavailable") || description.contains("not available") {
            return .storeUnavailable
        }
        return .unknown
    }
}
