//
//  FirebaseAnalyticsAdapter.swift
//  JetUI
//
//  Concrete JetAnalyticsProvider backed by Firebase Analytics.
//  Apps that don't use Firebase can substitute any other adapter without
//  touching JetUI internals.
//

import Foundation
import FirebaseAnalytics

/// Drop-in Firebase adapter.  Register at startup:
/// ```swift
/// JetAnalytics.shared.register(FirebaseAnalyticsAdapter())
/// ```
public final class FirebaseAnalyticsAdapter: JetAnalyticsProvider {

    public init() {}

    public func logEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }

    public func logScreen(_ screen: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screen,
            AnalyticsParameterScreenClass: "SwiftUI"
        ])
    }

    public func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }

    public func setUserID(_ userID: String?) {
        Analytics.setUserID(userID)
    }

    public func setCollectionEnabled(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
    }
}
