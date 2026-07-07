//
//  JetAppRuntime.swift
//  JetUI
//
//  App matrix runtime: product descriptor + module runtimes + injected actions.
//

import Foundation
import SwiftUI
import JetUIAnalytics
import JetUIDesign
import JetUISettings
import JetUISubscription

public struct JetLegalLinks: Equatable {
    public let termsOfUse: URL
    public let privacyPolicy: URL

    public init(termsOfUse: URL, privacyPolicy: URL) {
        self.termsOfUse = termsOfUse
        self.privacyPolicy = privacyPolicy
    }
}

public struct JetSupportConfig: Equatable {
    public let email: String
    public let subject: String

    public init(email: String, subject: String = "Feedback") {
        self.email = email
        self.subject = subject
    }
}

public struct JetSettingsProfile {
    public let sections: [JetSettingSection]

    public init(sections: [JetSettingSection]) {
        self.sections = sections
    }
}

public struct JetAppDescriptor {
    public let appId: String
    public let displayName: String
    public let legal: JetLegalLinks
    public let support: JetSupportConfig
    public let theme: JetThemeConfig
    public let settings: JetSettingsProfile
    public let subscription: JetSubscriptionConfig?

    public init(
        appId: String,
        displayName: String,
        legal: JetLegalLinks,
        support: JetSupportConfig,
        theme: JetThemeConfig,
        settings: JetSettingsProfile,
        subscription: JetSubscriptionConfig?
    ) {
        self.appId = appId
        self.displayName = displayName
        self.legal = legal
        self.support = support
        self.theme = theme
        self.settings = settings
        self.subscription = subscription
    }
}

public final class JetNoopAnalyticsProvider: JetAnalyticsProvider {
    public init() {}

    public func logEvent(_ name: String, parameters: [String: Any]?) {}
    public func logScreen(_ screen: String) {}
    public func setUserProperty(_ value: String?, forName name: String) {}
    public func setUserID(_ userID: String?) {}
    public func setCollectionEnabled(_ enabled: Bool) {}
}

@MainActor
public final class JetAppRuntime: ObservableObject {
    public let descriptor: JetAppDescriptor
    public let analytics: JetAnalyticsProvider
    public let subscription: JetSubscriptionRuntime?
    public let settingsActions: JetSettingsActionHandling

    public init(
        descriptor: JetAppDescriptor,
        analytics: JetAnalyticsProvider = JetNoopAnalyticsProvider(),
        settingsActions: JetSettingsActionHandling = JetDefaultSettingsActionHandler()
    ) {
        self.descriptor = descriptor
        self.analytics = analytics
        self.settingsActions = settingsActions
        self.subscription = descriptor.subscription.map { JetSubscriptionRuntime(config: $0) }
    }

    public func install() {
        JetUI.configureTheme(descriptor.theme)
        JetAnalytics.shared.register(analytics)

        if let subscription {
            JetUI.configureSubscriptionRuntime(subscription)
        }
    }
}

private struct JetAppRuntimeEnvironmentKey: EnvironmentKey {
    static let defaultValue: JetAppRuntime? = nil
}

public extension EnvironmentValues {
    var jetRuntime: JetAppRuntime? {
        get { self[JetAppRuntimeEnvironmentKey.self] }
        set { self[JetAppRuntimeEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func jetRuntime(_ runtime: JetAppRuntime) -> some View {
        modifier(JetAppRuntimeInstaller(runtime: runtime))
    }
}

private struct JetAppRuntimeInstaller: ViewModifier {
    let runtime: JetAppRuntime

    func body(content: Content) -> some View {
        content
            .environment(\.jetRuntime, runtime)
            .environment(\.jetSettingsActionHandler, runtime.settingsActions)
            .task { @MainActor in
                runtime.install()
            }
    }
}
