//
//  JetSettingsAction.swift
//  JetUI
//
//  Semantic settings actions and injectable execution.
//

import Foundation
import StoreKit
import SwiftUI

public enum JetSettingsAction: Equatable {
    case restorePurchases
    case share(text: String, appStoreURL: URL)
    case rateApp
    case openURL(URL)
    case feedback(email: String, subject: String)
    case custom(String)
}

public protocol JetSettingsActionHandling {
    func handle(_ action: JetSettingsAction) async
}

public final class JetDefaultSettingsActionHandler: JetSettingsActionHandling {
    public init() {}

    public func handle(_ action: JetSettingsAction) async {
        switch action {
        case .restorePurchases:
            try? await AppStore.sync()
        case .share(let text, let appStoreURL):
            await MainActor.run {
                JetSettingsActions.shareApp(text: text, appStoreURL: appStoreURL.absoluteString)
            }
        case .rateApp:
            await JetSettingsActions.requestReview()
        case .openURL(let url):
            await MainActor.run {
                JetSettingsActions.openURL(url.absoluteString)
            }
        case .feedback(let email, let subject):
            await MainActor.run {
                JetSettingsActions.sendFeedbackEmail(to: email, subject: subject)
            }
        case .custom:
            break
        }
    }
}

private struct JetSettingsActionHandlerEnvironmentKey: EnvironmentKey {
    static let defaultValue: JetSettingsActionHandling? = nil
}

public extension EnvironmentValues {
    var jetSettingsActionHandler: JetSettingsActionHandling? {
        get { self[JetSettingsActionHandlerEnvironmentKey.self] }
        set { self[JetSettingsActionHandlerEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func jetSettingsActionHandler(_ handler: JetSettingsActionHandling) -> some View {
        environment(\.jetSettingsActionHandler, handler)
    }
}
