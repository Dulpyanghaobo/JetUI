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
