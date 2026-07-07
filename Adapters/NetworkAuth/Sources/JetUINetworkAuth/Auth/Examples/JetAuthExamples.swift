//
//  JetAuthExamples.swift
//  JetUI
//
//  Example configurations and mock state for demonstrating AuthManager capabilities
//  in the module example app without performing real network or Keychain calls.
//

import Foundation

// MARK: - Auth State Examples

public enum JetAuthExamples {
    public struct StateSample {
        public let label: String
        public let description: String
        public let isLoggedIn: Bool
        public let planTier: String

        public init(label: String, description: String, isLoggedIn: Bool, planTier: String) {
            self.label = label
            self.description = description
            self.isLoggedIn = isLoggedIn
            self.planTier = planTier
        }
    }

    public static let states: [StateSample] = [
        StateSample(
            label: "Guest",
            description: "No authentication. App shows limited features until the user signs in.",
            isLoggedIn: false,
            planTier: "guest"
        ),
        StateSample(
            label: "Free User",
            description: "Authenticated via guest login. Has basic entitlement but no Pro subscription.",
            isLoggedIn: true,
            planTier: "free"
        ),
        StateSample(
            label: "Pro User",
            description: "Authenticated and has an active premium subscription. All features unlocked.",
            isLoggedIn: true,
            planTier: "premium"
        ),
    ]

    // MARK: - Keychain Keys Reference

    public struct KeychainKeyInfo {
        public let key: String
        public let description: String

        public init(key: String, description: String) {
            self.key = key
            self.description = description
        }
    }

    public static let keychainKeys: [KeychainKeyInfo] = [
        KeychainKeyInfo(
            key: AuthManager.KeychainKey.loginResult,
            description: "Persisted LoginResult including access token and user subscription info."
        ),
        KeychainKeyInfo(
            key: AuthManager.KeychainKey.userInfo,
            description: "Cached UserInfo with entitlement, quota, and cloud storage path."
        ),
        KeychainKeyInfo(
            key: AuthManager.KeychainKey.deviceId,
            description: "Stable IDFV-based device identifier used for API signing."
        ),
    ]

    // MARK: - Apple Sign-In Flow

    public struct AppleSignInStep {
        public let step: Int
        public let title: String
        public let detail: String

        public init(step: Int, title: String, detail: String) {
            self.step = step
            self.title = title
            self.detail = detail
        }
    }

    public static let appleSignInFlow: [AppleSignInStep] = [
        AppleSignInStep(step: 1, title: "Generate Nonce", detail: "AuthManager.randomNonceString() creates a one-time token to prevent replay attacks."),
        AppleSignInStep(step: 2, title: "Configure Request", detail: "configureAppleRequest(_:) sets scopes (.fullName, .email) and attaches the SHA-256 nonce hash."),
        AppleSignInStep(step: 3, title: "Handle Credential", detail: "On success, extract identityToken from ASAuthorizationAppleIDCredential and send to backend."),
        AppleSignInStep(step: 4, title: "Save LoginResult", detail: "Backend returns a LoginResult; call saveLoginResult(_:) to persist it in Keychain."),
    ]
}
