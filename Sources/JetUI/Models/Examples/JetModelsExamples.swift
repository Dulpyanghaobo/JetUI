//
//  JetModelsExamples.swift
//  JetUI
//
//  Example JetAppItem instances beyond the built-in company presets.
//  Demonstrates how host apps can supply custom app recommendation lists.
//

import Foundation

// MARK: - JetAppItem Custom Presets

public extension JetAppItem {
    /// Placeholder items that a host app can replace with real App Store links.
    @MainActor
    static let exampleFeaturedApps: [JetAppItem] = [
        JetAppItem(
            name: "TimeProof",
            localIconName: "TimeProof_icon",
            actionURL: URL(string: "https://apps.apple.com/app/timeproof-id")!
        ),
        JetAppItem(
            name: "JetScan",
            localIconName: "JetScan_icon",
            actionURL: URL(string: "https://apps.apple.com/app/scan-id")!
        ),
        JetAppItem(
            name: "JetFax",
            localIconName: "JetFax_icon",
            actionURL: URL(string: "https://apps.apple.com/app/fax-id")!
        ),
    ]

    /// A single-item list used in narrow recommendation rows.
    @MainActor
    static let exampleSingleApp: JetAppItem = JetAppItem(
        name: "Alarm",
        localIconName: "Alarm_icon",
        actionURL: URL(string: "https://apps.apple.com/app/alarm-id")!
    )
}

// MARK: - Model Usage Guide

public enum JetModelsExamples {
    public struct UsageNote {
        public let title: String
        public let detail: String

        public init(title: String, detail: String) {
            self.title = title
            self.detail = detail
        }
    }

    public static let notes: [UsageNote] = [
        UsageNote(
            title: "iconURL vs localIconName",
            detail: "Prefer localIconName for assets bundled in JetUI (Media.xcassets). Use iconURL for dynamically hosted icons fetched via JetCacheAsyncImage."
        ),
        UsageNote(
            title: "actionURL",
            detail: "Can be an App Store https URL or a custom deep-link scheme (e.g. myapp://open). UIApplication.shared.open handles both."
        ),
        UsageNote(
            title: "JetRecommendationsView",
            detail: "Pass a [JetAppItem] array to JetRecommendationsView to render a horizontal scrolling row of app icons with tap-to-open behavior."
        ),
    ]
}
