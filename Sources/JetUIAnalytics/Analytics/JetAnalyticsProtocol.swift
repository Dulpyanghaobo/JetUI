//
//  JetAnalyticsProtocol.swift
//  JetUI
//
//  Platform-agnostic analytics protocol.
//  JetUI depends only on this protocol; Firebase is one swappable adapter.
//

import Foundation

// MARK: - Protocol

/// Implement this protocol to plug any analytics backend into JetUI.
public protocol JetAnalyticsProvider: AnyObject {
    /// Log a named event with optional parameters.
    func logEvent(_ name: String, parameters: [String: Any]?)

    /// Log a screen view.
    func logScreen(_ screen: String)

    /// Set a per-user property (pass nil to clear).
    func setUserProperty(_ value: String?, forName name: String)

    /// Associate a user ID with subsequent events (pass nil to clear).
    func setUserID(_ userID: String?)

    /// Enable or disable collection globally.
    func setCollectionEnabled(_ enabled: Bool)
}

// MARK: - Registry

/// Central registry.  JetUI modules call `JetAnalytics.shared` rather than
/// importing any concrete analytics SDK.
public final class JetAnalytics {

    public static let shared = JetAnalytics()

    private var provider: JetAnalyticsProvider?

    private init() {}

    /// Register the active provider (typically called at app startup).
    public func register(_ provider: JetAnalyticsProvider) {
        self.provider = provider
    }

    // MARK: Forwarding helpers (mirror AnalyticsManager's public API)

    public func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        provider?.logEvent(name, parameters: parameters)
    }

    public func logScreen(_ screen: String) {
        provider?.logScreen(screen)
    }

    public func setUserProperty(_ value: String?, forName name: String) {
        provider?.setUserProperty(value, forName: name)
    }

    public func setUserID(_ userID: String?) {
        provider?.setUserID(userID)
    }

    public func setCollectionEnabled(_ enabled: Bool) {
        provider?.setCollectionEnabled(enabled)
    }
}
