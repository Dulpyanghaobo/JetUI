//
//  JetFirebaseBootstrap.swift
//  JetUIFirebaseAdapters
//
//  Central Firebase bootstrap helpers for host apps that opt in to Firebase.
//

import Foundation
import FirebaseCore
import FirebaseMessaging
import JetUI

/// Receives Firebase Cloud Messaging registration token updates without exposing FirebaseMessaging to host apps.
public protocol JetFirebaseMessagingTokenHandler: AnyObject {
    func jetFirebaseMessaging(didReceiveRegistrationToken fcmToken: String?)
}

/// Firebase setup options used by JetFirebaseBootstrap.
public struct JetFirebaseBootstrapConfiguration {
    public let configureFirebaseApp: Bool
    public let registerCloudStorage: Bool
    public let storageRootPathProvider: JetStorageRootPathProvider
    public let messagingTokenHandler: JetFirebaseMessagingTokenHandler?

    public init(
        configureFirebaseApp: Bool = true,
        registerCloudStorage: Bool = true,
        storageRootPathProvider: JetStorageRootPathProvider = .deviceDefault,
        messagingTokenHandler: JetFirebaseMessagingTokenHandler? = nil
    ) {
        self.configureFirebaseApp = configureFirebaseApp
        self.registerCloudStorage = registerCloudStorage
        self.storageRootPathProvider = storageRootPathProvider
        self.messagingTokenHandler = messagingTokenHandler
    }
}

/// APNS token environment without exposing FirebaseMessaging symbols to host apps.
public enum JetFirebaseAPNSTokenType {
    case unknown
    case sandbox
    case production

    fileprivate var firebaseTokenType: MessagingAPNSTokenType {
        switch self {
        case .unknown:
            return .unknown
        case .sandbox:
            return .sandbox
        case .production:
            return .prod
        }
    }
}

/// Configures Firebase services owned by the Firebase adapter package.
public enum JetFirebaseBootstrap {
    public static func configure(_ configuration: JetFirebaseBootstrapConfiguration = JetFirebaseBootstrapConfiguration()) {
        if configuration.configureFirebaseApp, FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        if configuration.registerCloudStorage {
            JetStorageManager.shared.configureRootPathProvider(configuration.storageRootPathProvider)
            JetCloudStorage.shared.register(JetStorageManager.shared)
        }

        JetFirebaseMessagingDelegateAdapter.shared.relay.handler = configuration.messagingTokenHandler
        Messaging.messaging().delegate = JetFirebaseMessagingDelegateAdapter.shared
    }

    public static func setAPNSToken(
        _ token: Data,
        type: JetFirebaseAPNSTokenType = .unknown
    ) {
        Messaging.messaging().setAPNSToken(token, type: type.firebaseTokenType)
    }

    public static func messagingToken() async throws -> String {
        try await Messaging.messaging().token()
    }
}

final class JetFirebaseMessagingTokenRelay {
    weak var handler: JetFirebaseMessagingTokenHandler?

    func forwardRegistrationToken(_ fcmToken: String?) {
        handler?.jetFirebaseMessaging(didReceiveRegistrationToken: fcmToken)
    }
}

private final class JetFirebaseMessagingDelegateAdapter: NSObject, MessagingDelegate {
    static let shared = JetFirebaseMessagingDelegateAdapter()

    let relay = JetFirebaseMessagingTokenRelay()

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        relay.forwardRegistrationToken(fcmToken)
    }
}
