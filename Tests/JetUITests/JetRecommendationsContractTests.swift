import XCTest
@testable import JetUI

final class JetRecommendationsContractTests: XCTestCase {
    func testAppItemKeepsRecommendationMetadataOptional() {
        let item = JetAppItem(
            name: "Scanner",
            actionURL: URL(string: "https://example.com/scanner")!
        )

        XCTAssertNil(item.subtitle)
        XCTAssertNil(item.actionTitle)
        XCTAssertNil(item.product)
    }

    func testAppItemStoresRecommendationMetadata() {
        let item = JetAppItem(
            name: "Scanner",
            subtitle: "Scan and export documents",
            actionTitle: "Get",
            actionURL: URL(string: "https://example.com/scanner")!
        )

        XCTAssertEqual(item.subtitle, "Scan and export documents")
        XCTAssertEqual(item.actionTitle, "Get")
    }

    func testAppItemStoresFallbackURLAndDisclosurePreference() {
        let fallbackURL = URL(string: "https://apps.apple.com/us/app/jet-camera-timeproof-camera/id6755984821")!
        let item = JetAppItem(
            name: "TimeProof",
            actionURL: URL(string: "JetTimeProof://")!,
            fallbackURL: fallbackURL,
            showsDisclosureIndicator: false
        )

        XCTAssertEqual(item.actionURL.absoluteString, "JetTimeProof://")
        XCTAssertEqual(item.fallbackURL, fallbackURL)
        XCTAssertFalse(item.showsDisclosureIndicator)
    }

    func testCompanyAppsUseDeepLinksWithStoreFallbacksAndOpenButtons() throws {
        let timeStamp = try XCTUnwrap(JetAppItem.companyApps.first { $0.name == "TimeStamp" })
        XCTAssertEqual(timeStamp.actionURL.absoluteString, "JetCamera://")
        XCTAssertEqual(
            timeStamp.fallbackURL?.absoluteString,
            "https://apps.apple.com/us/app/stampcam-photo-video/id6747913178"
        )
        XCTAssertEqual(timeStamp.actionTitle, "Open")
        XCTAssertEqual(timeStamp.product, .timeStamp)
        XCTAssertEqual(timeStamp.actionBackgroundColorHex, 0xFFA800)
        XCTAssertEqual(timeStamp.actionTextColorHex, 0x000000)

        let timeProof = try XCTUnwrap(JetAppItem.companyApps.first { $0.name == "TimeProof" })
        XCTAssertEqual(timeProof.actionURL.absoluteString, "JetTimeProof://")
        XCTAssertEqual(
            timeProof.fallbackURL?.absoluteString,
            "https://apps.apple.com/us/app/jet-camera-timeproof-camera/id6755984821"
        )
        XCTAssertEqual(timeProof.actionTitle, "Open")
        XCTAssertEqual(timeProof.product, .timeProof)
        XCTAssertEqual(timeProof.actionBackgroundColorHex, 0x2786D5)

        let jetFax = try XCTUnwrap(JetAppItem.companyApps.first { $0.name == "JetFax" })
        XCTAssertEqual(jetFax.actionURL.absoluteString, "jetfax://")
        XCTAssertEqual(
            jetFax.fallbackURL?.absoluteString,
            "https://apps.apple.com/us/app/jet-fax-fax-from-iphone-free/id6752217283"
        )
        XCTAssertEqual(jetFax.actionTitle, "Open")
        XCTAssertEqual(jetFax.product, .jetFax)
        XCTAssertEqual(jetFax.actionBackgroundColorHex, 0x0A7AF5)

        for item in [timeStamp, timeProof, jetFax] {
            XCTAssertFalse(item.showsDisclosureIndicator)
        }
    }

    func testProductCatalogNamesJetScanAndExcludesTheCurrentProduct() {
        XCTAssertEqual(JetProduct.jetScan.displayName, "JetScan")
        XCTAssertEqual(JetAppLauncher.item(for: .jetFax)?.name, "JetFax")
        XCTAssertNil(JetAppLauncher.item(for: .jetScan))

        let recommendations = JetAppLauncher.recommendations(excluding: .jetScan)
        XCTAssertFalse(recommendations.contains { $0.product == .jetScan })
        XCTAssertEqual(recommendations.map(\.product).compactMap { $0 }.count, 3)
    }

    func testRecommendationsViewSupportsNewStyleConfiguration() {
        _ = JetRecommendationsView()
        _ = JetRecommendationsView(style: .sectionedRows, appearance: .light)
        _ = JetRecommendationsView(style: .iconCarousel, appearance: .dark)
    }

    func testSettingsConfigurationKeepsTopContentOptionalByDefault() {
        let configuration = JetSettingsConfiguration(sections: [])

        XCTAssertNil(configuration.topContentView)
    }

    func testSettingItemStoresOptionalSubtitle() {
        let item = JetSettingItem(
            icon: .system("sparkles"),
            title: "AI Summary",
            subtitle: "Generate highlights and tasks",
            action: {}
        )

        XCTAssertEqual(item.subtitle, "Generate highlights and tasks")
    }

    func testSettingItemKeepsSubtitleOptionalForExistingCallers() {
        let item = JetSettingItem(
            icon: .system("arrow.clockwise"),
            title: "Restore",
            detail: "Available",
            action: {}
        )

        XCTAssertNil(item.subtitle)
        XCTAssertEqual(item.detail, "Available")
    }

    func testNewSettingsComponentsAreConstructible() {
        _ = JetSettingsProductHeaderCard(
            appIcon: .system("doc.text.viewfinder"),
            title: "JetScan",
            subtitle: "AI PDF Assistant",
            description: "Scan, recognize, summarize, sign, and convert.",
            versionText: "Version 1.0",
            actionTitle: "Learn more",
            action: {}
        )

        _ = JetRecommendationsSummaryRow(
            title: "More Tools",
            subtitle: "Discover photo, watermark, fax, and productivity apps.",
            items: [
                JetAppItem(name: "Scanner", actionURL: URL(string: "https://example.com/scanner")!),
                JetAppItem(name: "Fax", actionURL: URL(string: "https://example.com/fax")!)
            ],
            actionTitle: "View All",
            action: {}
        )
    }
}
