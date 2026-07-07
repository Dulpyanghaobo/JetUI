import XCTest
@testable import JetUI

@MainActor
final class JetAppRuntimeContractTests: XCTestCase {
    func testRuntimeInstallsDescriptorIntoLegacyEntrypoints() {
        let subscriptionConfig = JetSubscriptionConfig(
            productIds: ["matrix.weekly"],
            proProductIds: ["matrix.weekly"],
            groupId: "matrix",
            appIdentifier: "com.example.matrix"
        )
        let descriptor = JetAppDescriptor(
            appId: "matrix",
            displayName: "Matrix App",
            legal: JetLegalLinks(
                termsOfUse: URL(string: "https://example.com/terms")!,
                privacyPolicy: URL(string: "https://example.com/privacy")!
            ),
            support: JetSupportConfig(email: "support@example.com"),
            theme: RuntimeContractTheme(),
            settings: JetSettingsProfile(sections: []),
            subscription: subscriptionConfig
        )
        let analytics = RecordingAnalyticsProvider()
        let settingsActions = RecordingSettingsActionHandler()

        let runtime = JetAppRuntime(
            descriptor: descriptor,
            analytics: analytics,
            settingsActions: settingsActions
        )

        runtime.install()

        XCTAssertEqual(runtime.descriptor.appId, "matrix")
        XCTAssertTrue(JetUI.theme is RuntimeContractTheme)
        XCTAssertEqual(JetUI.subscriptionRuntime?.config.appIdentifier, "com.example.matrix")
    }

    func testRuntimeKeepsSettingsActionHandlerInjectable() async throws {
        let runtime = JetAppRuntime(
            descriptor: .testDescriptor(subscription: nil),
            analytics: RecordingAnalyticsProvider(),
            settingsActions: RecordingSettingsActionHandler()
        )

        await runtime.settingsActions.handle(.openURL(URL(string: "https://example.com/help")!))

        let recorder = try XCTUnwrap(runtime.settingsActions as? RecordingSettingsActionHandler)
        let actions = await recorder.recordedActions()
        XCTAssertEqual(actions, [.openURL(URL(string: "https://example.com/help")!)])
    }

    func testRuntimeCanUseNoopAnalyticsForLightweightApps() {
        let runtime = JetAppRuntime(descriptor: .testDescriptor(subscription: nil))

        XCTAssertTrue(runtime.analytics is JetNoopAnalyticsProvider)
    }
}

final class JetSettingsActionContractTests: XCTestCase {
    func testSettingsActionIsSemanticAndEquatable() {
        XCTAssertEqual(
            JetSettingsAction.feedback(email: "support@example.com", subject: "Help"),
            JetSettingsAction.feedback(email: "support@example.com", subject: "Help")
        )
        XCTAssertNotEqual(
            JetSettingsAction.restorePurchases,
            JetSettingsAction.rateApp
        )
    }
}

final class JetAnalyticsBoundaryTests: XCTestCase {
    func testAnalyticsDefinitionsKeepPlatformModuleAndProductScopesSeparate() {
        XCTAssertEqual(JetAnalyticsEventDefinition.appOpen.scope, .platform)
        XCTAssertEqual(JetAnalyticsEventDefinition.subscription(.purchaseStart).scope, .subscription)
        XCTAssertEqual(JetAnalyticsEventDefinition.settings(.action).scope, .settings)
        XCTAssertEqual(JetAnalyticsEventDefinition.product("camera_open").scope, .product)
    }
}

private final class RecordingAnalyticsProvider: JetAnalyticsProvider {
    func logEvent(_ name: String, parameters: [String: Any]?) {}
    func logScreen(_ screen: String) {}
    func setUserProperty(_ value: String?, forName name: String) {}
    func setUserID(_ userID: String?) {}
    func setCollectionEnabled(_ enabled: Bool) {}
}

private actor RecordingSettingsActionHandler: JetSettingsActionHandling {
    private(set) var actions: [JetSettingsAction] = []

    func handle(_ action: JetSettingsAction) async {
        actions.append(action)
    }

    func recordedActions() -> [JetSettingsAction] {
        actions
    }
}

private struct RuntimeContractTheme: JetThemeConfig {
    let colors: JetColorPalette = DefaultColorPalette()
    let fonts: JetTypography = DefaultTypography()
    let layout: JetLayoutConfig = DefaultLayoutConfig()
}

private extension JetAppDescriptor {
    static func testDescriptor(subscription: JetSubscriptionConfig?) -> JetAppDescriptor {
        JetAppDescriptor(
            appId: "test",
            displayName: "Test App",
            legal: JetLegalLinks(
                termsOfUse: URL(string: "https://example.com/terms")!,
                privacyPolicy: URL(string: "https://example.com/privacy")!
            ),
            support: JetSupportConfig(email: "support@example.com"),
            theme: RuntimeContractTheme(),
            settings: JetSettingsProfile(sections: []),
            subscription: subscription
        )
    }
}
