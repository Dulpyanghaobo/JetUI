import XCTest
@testable import JetUI

final class JetUIModuleExampleCatalogTests: XCTestCase {
    func testCatalogCoversTopLevelJetUIModules() {
        let moduleIDs = JetUIModuleExampleCatalog.modules.map(\.id)

        XCTAssertEqual(moduleIDs, [
            "runtime",
            "components",
            "core",
            "design",
            "settings",
            "subscription",
            "analytics",
            "onboarding",
            "adapters"
        ])
    }

    func testEveryModuleHasDisplayMetadataAndAtLeastOneExample() {
        for module in JetUIModuleExampleCatalog.modules {
            XCTAssertFalse(module.title.isEmpty)
            XCTAssertFalse(module.summary.isEmpty)
            XCTAssertFalse(module.systemImage.isEmpty)
            XCTAssertFalse(module.examples.isEmpty, "\(module.title) should expose at least one example")
        }
    }
}
