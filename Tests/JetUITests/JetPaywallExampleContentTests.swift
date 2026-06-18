import XCTest
@testable import JetUI

final class JetPaywallExampleContentTests: XCTestCase {
    func testExampleTrialContentUsesOnePublicContentModel() {
        let content = JetPaywallContent.exampleTimeProofTrial

        XCTAssertEqual(content.brandTitle, "How Free Trial Works")
        XCTAssertEqual(content.continueText, "Continue")
        XCTAssertEqual(content.restoreText, "Restore")
        XCTAssertEqual(content.benefits.count, 4)
        XCTAssertEqual(content.timelineSteps.count, 3)
        XCTAssertEqual(content.complexBenefits.count, 4)
        XCTAssertEqual(content.privacyPolicyURL?.host, "www.freeprivacypolicy.com")
        XCTAssertEqual(content.termsURL?.host, "www.apple.com")
    }

    func testExampleFullContentIsListReady() {
        let content = JetPaywallContent.exampleTimeProofFull

        XCTAssertEqual(content.brandTitle, "GPS CAM PRO")
        XCTAssertEqual(content.highlightKeyword, "PRO")
        XCTAssertEqual(content.benefits.count, 4)
        XCTAssertTrue(content.timelineSteps.isEmpty)
        XCTAssertTrue(content.complexBenefits.isEmpty)
        XCTAssertEqual(content.privacyPolicyURL?.host, "www.freeprivacypolicy.com")
        XCTAssertEqual(content.termsURL?.host, "www.apple.com")
    }
}
