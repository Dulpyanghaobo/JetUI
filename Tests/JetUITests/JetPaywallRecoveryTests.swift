import XCTest
@testable import JetUI

final class JetPaywallRecoveryTests: XCTestCase {
    func testNetworkPurchaseFailureBuildsRecoverableRetryRestoreState() {
        let category = JetPaywallFailureCategory.category(for: URLError(.notConnectedToInternet))
        XCTAssertEqual(category, .network)
        XCTAssertTrue(category.isRecoverable)

        let recovery = JetPaywallRecoveryState(error: URLError(.notConnectedToInternet))
        XCTAssertEqual(recovery.reasonCategory, "network")
        XCTAssertFalse(recovery.title.isEmpty)
        XCTAssertFalse(recovery.message.isEmpty)
        XCTAssertFalse(recovery.retryTitle.isEmpty)
        XCTAssertFalse(recovery.restoreTitle.isEmpty)
    }

    func testCancelledPurchaseIsNotRecoverable() {
        let category = JetPaywallFailureCategory.category(for: JetStoreError.cancelled)
        XCTAssertEqual(category, .userCancelled)
        XCTAssertFalse(category.isRecoverable)
        XCTAssertNil(JetPaywallRecoveryState(error: JetStoreError.cancelled))
    }

    func testStoreKitUnavailableProductBuildsRecoverableStoreState() {
        let category = JetPaywallFailureCategory.category(for: SKError(.storeProductNotAvailable))
        XCTAssertEqual(category, .storeUnavailable)
        XCTAssertTrue(category.isRecoverable)

        let recovery = JetPaywallRecoveryState(error: SKError(.storeProductNotAvailable))
        XCTAssertEqual(recovery.reasonCategory, "store_unavailable")
        XCTAssertFalse(recovery.message.isEmpty)
    }

    func testStoreKitPaymentCancelledStaysOutOfRecoveryState() {
        let category = JetPaywallFailureCategory.category(for: SKError(.paymentCancelled))
        XCTAssertEqual(category, .userCancelled)
        XCTAssertFalse(category.isRecoverable)
        XCTAssertNil(JetPaywallRecoveryState(error: SKError(.paymentCancelled)))
    }

    func testPaywallAnalyticsPayloadUsesReasonCategoryWithoutRawErrorText() {
        let payload = AnalyticsManager.paywallOperationParameters(
            operation: "purchase",
            productId: "watermark_pro_yearly",
            paywallSource: "cold_launch",
            reasonCategory: .network,
            entitlementActive: false
        )

        XCTAssertEqual(payload["operation"] as? String, "purchase")
        XCTAssertEqual(payload["product_id"] as? String, "watermark_pro_yearly")
        XCTAssertEqual(payload["paywall_source"] as? String, "cold_launch")
        XCTAssertEqual(payload["reason_category"] as? String, "network")
        XCTAssertEqual(payload["entitlement_active"] as? Bool, false)
        XCTAssertNil(payload["error"])
        XCTAssertNil(payload["localizedDescription"])
    }

    func testPaywallFunnelEventsMatchProductSnapshotNames() {
        XCTAssertEqual(JetPaywallEvent.purchaseStart, "purchase_start")
        XCTAssertEqual(JetPaywallEvent.purchaseSuccess, "purchase_success")
        XCTAssertEqual(JetPaywallEvent.purchaseFailed, "purchase_failure")
        XCTAssertEqual(JetPaywallEvent.restoreStart, "restore_purchase")
        XCTAssertEqual(JetPaywallEvent.entitlementRefresh, "entitlement_refresh")
    }

    func testPaywallAnalyticsPayloadIncludesAppVersionAndSourceForRestore() {
        let payload = AnalyticsManager.paywallOperationParameters(
            operation: "restore",
            productId: nil,
            paywallSource: "settings",
            reasonCategory: .notEntitled,
            entitlementActive: false
        )

        XCTAssertEqual(payload["operation"] as? String, "restore")
        XCTAssertEqual(payload["product_id"] as? String, "none")
        XCTAssertEqual(payload["paywall_source"] as? String, "settings")
        XCTAssertEqual(payload["reason_category"] as? String, "not_entitled")
        XCTAssertEqual(payload["entitlement_active"] as? Bool, false)
        XCTAssertNotNil(payload["app_version"])
    }
}
