import XCTest
@testable import JetUIFirebaseAdapters

final class JetStorageRootPathProviderTests: XCTestCase {
    func testInjectedRootPathIsNormalizedWithTrailingSlash() {
        let provider = JetStorageRootPathProvider {
            "timestamp/ios/user-123"
        }

        XCTAssertEqual(provider.currentRootPath(), "timestamp/ios/user-123/")
    }

    func testBlankInjectedRootPathFallsBackToUnknownDevicePath() {
        let provider = JetStorageRootPathProvider {
            "   "
        }

        XCTAssertEqual(provider.currentRootPath(), "timestamp/ios/unknown-device/")
    }

    func testDeviceRootPathUsesProvidedDeviceId() {
        XCTAssertEqual(
            JetStorageRootPathProvider.deviceRootPath(deviceId: "device-abc"),
            "timestamp/ios/device-abc/"
        )
    }
}
