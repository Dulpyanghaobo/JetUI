import XCTest
@testable import JetUIFirebaseAdapters

final class JetFirebaseBootstrapTests: XCTestCase {
    func testConfigurationCarriesStorageAndMessagingDefaults() {
        let handler = MessagingTokenHandlerSpy()
        let configuration = JetFirebaseBootstrapConfiguration(
            storageRootPathProvider: JetStorageRootPathProvider {
                "timestamp/ios/user-123"
            },
            messagingTokenHandler: handler
        )

        XCTAssertTrue(configuration.configureFirebaseApp)
        XCTAssertTrue(configuration.registerCloudStorage)
        XCTAssertEqual(configuration.storageRootPathProvider.currentRootPath(), "timestamp/ios/user-123/")
        XCTAssertTrue(configuration.messagingTokenHandler === handler)
    }

    func testMessagingTokenRelayForwardsRegistrationToken() {
        let handler = MessagingTokenHandlerSpy()
        let relay = JetFirebaseMessagingTokenRelay()

        relay.handler = handler
        relay.forwardRegistrationToken("fcm-token")

        XCTAssertEqual(handler.receivedTokens, ["fcm-token"])
    }
}

private final class MessagingTokenHandlerSpy: JetFirebaseMessagingTokenHandler {
    private(set) var receivedTokens: [String?] = []

    func jetFirebaseMessaging(didReceiveRegistrationToken fcmToken: String?) {
        receivedTokens.append(fcmToken)
    }
}
