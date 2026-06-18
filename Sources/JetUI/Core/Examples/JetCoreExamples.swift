//
//  JetCoreExamples.swift
//  JetUI
//
//  Example data and configurations for JetUI Core utilities:
//  CacheManager, CSLogger, CircuitBreaker, and date formatting.
//

import Foundation

// MARK: - Cache Examples

public enum JetCacheExamples {
    public struct UserPreferences: Codable, Sendable {
        public let userId: String
        public let language: String
        public let notificationsEnabled: Bool

        public init(userId: String, language: String, notificationsEnabled: Bool) {
            self.userId = userId
            self.language = language
            self.notificationsEnabled = notificationsEnabled
        }
    }

    public static let examplePreferences = UserPreferences(
        userId: "usr_demo_001",
        language: "en",
        notificationsEnabled: true
    )

    public static let shortTTL: TimeInterval = 60        // 1 minute
    public static let standardTTL: TimeInterval = 900    // 15 minutes
    public static let longTTL: TimeInterval = 3600       // 1 hour

    public static let keys = (
        userPrefs: "example.userPreferences",
        appConfig: "example.appConfig",
        featureFlags: "example.featureFlags"
    )
}

// MARK: - Logger Examples

public enum JetLoggerExamples {
    public struct LogSample {
        public let message: String
        public let category: LogCategory
        public let level: String

        public init(message: String, category: LogCategory, level: String) {
            self.message = message
            self.category = category
            self.level = level
        }
    }

    public static let samples: [LogSample] = [
        LogSample(message: "App launched successfully", category: .general, level: "info"),
        LogSample(message: "Fetching subscription products…", category: .network, level: "debug"),
        LogSample(message: "Cache hit for key: user.profile", category: .database, level: "debug"),
        LogSample(message: "Memory warning received (level: critical)", category: .general, level: "warning"),
        LogSample(message: "Payment sheet dismissed", category: .ui, level: "info"),
    ]

    public static let subsystem = "com.example.JetUI.demo"
}

// MARK: - Date Formatter Examples

public enum JetDateExamples {
    public static let iso8601Strings: [String] = [
        "2026-06-18T09:30:00Z",
        "2026-01-01T00:00:00Z",
        "2025-12-25T12:00:00Z",
    ]

    public static let timestamps: [TimeInterval] = [
        1_750_240_200,  // sample epoch
        1_735_689_600,  // Jan 1 2025
        1_756_080_000,  // Aug 2025
    ]
}

// MARK: - Circuit Breaker Examples

public enum JetCircuitBreakerExamples {
    public struct BreakerConfig {
        public let name: String
        public let failureThreshold: Int
        public let resetTimeout: TimeInterval
        public let description: String

        public init(name: String, failureThreshold: Int, resetTimeout: TimeInterval, description: String) {
            self.name = name
            self.failureThreshold = failureThreshold
            self.resetTimeout = resetTimeout
            self.description = description
        }
    }

    public static let networkAPI = BreakerConfig(
        name: "NetworkAPI",
        failureThreshold: 3,
        resetTimeout: 30,
        description: "Protects outbound API calls from cascading failures."
    )
    public static let subscriptionService = BreakerConfig(
        name: "SubscriptionService",
        failureThreshold: 5,
        resetTimeout: 60,
        description: "Guards StoreKit calls; resets after 60s to retry."
    )

    public static let all: [BreakerConfig] = [networkAPI, subscriptionService]
}
