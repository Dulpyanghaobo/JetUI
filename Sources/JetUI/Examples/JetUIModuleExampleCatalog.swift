//
//  JetUIModuleExampleCatalog.swift
//  JetUI
//
//  Shared metadata for JetUI's module example apps and tests.
//

import Foundation

public struct JetUIModuleExample: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let summary: String
    public let systemImage: String
    public let examples: [String]

    public init(
        id: String,
        title: String,
        summary: String,
        systemImage: String,
        examples: [String]
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.systemImage = systemImage
        self.examples = examples
    }
}

public enum JetUIModuleExampleCatalog {
    public static let modules: [JetUIModuleExample] = [
        JetUIModuleExample(
            id: "runtime",
            title: "Runtime",
            summary: "Product descriptors, app matrix setup, theme installation, analytics provider injection, and settings action routing.",
            systemImage: "switch.2",
            examples: ["JetAppDescriptor", "JetAppRuntime", "SwiftUI environment injection"]
        ),
        JetUIModuleExample(
            id: "components",
            title: "Components",
            summary: "Reusable SwiftUI building blocks such as toast, alert, switch, glass, and cached image views.",
            systemImage: "square.grid.2x2",
            examples: ["Toast", "Custom switch", "Glass card", "Input alert", "Custom alert"]
        ),
        JetUIModuleExample(
            id: "core",
            title: "Core",
            summary: "Logging, cache, resilience, date formatting, state helpers, and shared utilities.",
            systemImage: "cpu",
            examples: ["Date formatting", "Cache state", "Circuit breaker", "State helper"]
        ),
        JetUIModuleExample(
            id: "design",
            title: "Design",
            summary: "Theme registry, semantic colors, typography, spacing, radius, and layout helpers.",
            systemImage: "paintpalette",
            examples: ["Color palette", "Typography", "Spacing", "Icon button"]
        ),
        JetUIModuleExample(
            id: "settings",
            title: "Settings",
            summary: "Configurable settings screens, semantic actions, app recommendations, and bundled recommendation assets.",
            systemImage: "gearshape",
            examples: ["Settings", "Membership card", "Recommendation rows", "Action handler"]
        ),
        JetUIModuleExample(
            id: "subscription",
            title: "Subscription",
            summary: "StoreKit runtime, entitlement cache, transaction observer, paywall view models, and paywall views.",
            systemImage: "creditcard",
            examples: ["Paywall", "Entitlement cache", "Runtime injection", "Recovery state"]
        ),
        JetUIModuleExample(
            id: "analytics",
            title: "Analytics",
            summary: "Provider protocol, typed event definitions, common payload helpers, and module-safe event scopes.",
            systemImage: "chart.bar.xaxis",
            examples: ["Provider registration", "Platform events", "Paywall payloads", "Product events"]
        ),
        JetUIModuleExample(
            id: "onboarding",
            title: "Onboarding",
            summary: "Lightweight SwiftUI onboarding screens kept in the umbrella package.",
            systemImage: "rectangle.stack.badge.play",
            examples: ["Onboarding pages", "Completion callback"]
        ),
        JetUIModuleExample(
            id: "adapters",
            title: "Adapters",
            summary: "Optional packages for Firebase, Lottie, NetworkAuth, storage, backend binding, and other product-specific SDKs.",
            systemImage: "puzzlepiece",
            examples: ["Firebase analytics adapter", "Firebase storage adapter", "Lottie adapter", "NetworkAuth adapter"]
        )
    ]
}
