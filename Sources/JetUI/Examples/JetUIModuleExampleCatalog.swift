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
            id: "auth",
            title: "Auth",
            summary: "Authentication state, guest login flow, token persistence, and session handoff.",
            systemImage: "person.crop.circle.badge.checkmark",
            examples: ["AuthManager status", "Auth configuration snippet"]
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
            id: "extensions",
            title: "Extensions",
            summary: "Convenience APIs on SwiftUI View, Color, and UIImage for common app UI work.",
            systemImage: "puzzlepiece.extension",
            examples: ["Back button modifier", "Conditional view modifier", "Image resize/tint snippet"]
        ),
        JetUIModuleExample(
            id: "features",
            title: "Features",
            summary: "Higher-level feature screens including onboarding, settings, and subscription paywalls.",
            systemImage: "sparkles.rectangle.stack",
            examples: ["Onboarding", "Settings", "Membership card", "Paywall"]
        ),
        JetUIModuleExample(
            id: "firebase",
            title: "Firebase",
            summary: "Analytics and storage wrappers used by product apps after Firebase is configured.",
            systemImage: "flame",
            examples: ["Analytics event snippet", "Storage upload snippet"]
        ),
        JetUIModuleExample(
            id: "models",
            title: "Models",
            summary: "Shared value models and presets for app recommendations and cross-module configuration.",
            systemImage: "shippingbox",
            examples: ["JetAppItem presets", "Recommendation rows"]
        ),
        JetUIModuleExample(
            id: "network",
            title: "Network",
            summary: "Moya targets, API response decoding, account service, auth session, and error models.",
            systemImage: "network",
            examples: ["API configuration", "Auth session", "Response decoding"]
        ),
        JetUIModuleExample(
            id: "resources",
            title: "Resources",
            summary: "Bundled assets and localized strings exposed by JetUI modules.",
            systemImage: "photo.on.rectangle.angled",
            examples: ["App icons", "Subscription strings"]
        ),
        JetUIModuleExample(
            id: "theme",
            title: "Theme",
            summary: "Design tokens, semantic colors, typography, spacing, radius, and layout helpers.",
            systemImage: "paintpalette",
            examples: ["Color palette", "Typography", "Spacing", "Icon button"]
        )
    ]
}
