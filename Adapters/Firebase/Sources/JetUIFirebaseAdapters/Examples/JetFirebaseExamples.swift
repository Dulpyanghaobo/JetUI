//
//  JetFirebaseExamples.swift
//  JetUI
//
//  Example event names, parameters, and user properties for AnalyticsManager,
//  plus storage path conventions for JetStorageManager.
//  Used by the module example app to show Firebase integration without live calls.
//

import Foundation

// MARK: - Analytics Event Examples

public enum JetFirebaseExamples {
    public struct EventSample {
        public let eventName: String
        public let parameters: [String: String]
        public let description: String

        public init(eventName: String, parameters: [String: String], description: String) {
            self.eventName = eventName
            self.parameters = parameters
            self.description = description
        }
    }

    public static let analyticsEvents: [EventSample] = [
        EventSample(
            eventName: "screen_view",
            parameters: ["screen_name": "HomeScreen", "screen_class": "SwiftUI"],
            description: "Logged whenever a major screen appears."
        ),
        EventSample(
            eventName: "paywall_view",
            parameters: ["variant": "trial", "source": "onboarding"],
            description: "Paywall impression — used to compute conversion funnel."
        ),
        EventSample(
            eventName: "purchase_success",
            parameters: ["product_id": "com.example.pro.monthly", "plan_type": "monthly"],
            description: "Fired after StoreKit confirms the transaction."
        ),
        EventSample(
            eventName: "button_click",
            parameters: ["name": "CaptureButton", "pro": "false"],
            description: "Generic CTA tap tracker; contexts injected from AnalyticsContext."
        ),
        EventSample(
            eventName: "onboarding_step",
            parameters: ["step": "2", "action": "next"],
            description: "Tracks onboarding flow completion per step."
        ),
    ]

    // MARK: - User Properties

    public struct UserPropertySample {
        public let name: String
        public let exampleValue: String
        public let description: String

        public init(name: String, exampleValue: String, description: String) {
            self.name = name
            self.exampleValue = exampleValue
            self.description = description
        }
    }

    public static let userProperties: [UserPropertySample] = [
        UserPropertySample(name: "is_pro", exampleValue: "true", description: "Set after subscription is confirmed."),
        UserPropertySample(name: "app_locale", exampleValue: "en_US", description: "Device locale at session start."),
        UserPropertySample(name: "plan_tier", exampleValue: "premium", description: "Backend-returned plan tier string."),
    ]

    // MARK: - Storage Path Examples

    public struct StoragePathSample {
        public let path: String
        public let description: String

        public init(path: String, description: String) {
            self.path = path
            self.description = description
        }
    }

    public static let storagePaths: [StoragePathSample] = [
        StoragePathSample(
            path: "timestamp/ios/<deviceId>/photos/IMG_001.jpg",
            description: "User-captured photo stored under their device namespace."
        ),
        StoragePathSample(
            path: "timestamp/ios/<deviceId>/exports/export_2026.zip",
            description: "Bulk export archive uploaded for cloud sync."
        ),
        StoragePathSample(
            path: "public/templates/watermark_gold.png",
            description: "Shared template asset readable by all users."
        ),
    ]
}
