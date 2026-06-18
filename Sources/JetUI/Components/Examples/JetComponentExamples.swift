//
//  JetComponentExamples.swift
//  JetUI
//
//  Example configurations for JetUI components (Toast, Alert, Glass, Switch, Image).
//

import SwiftUI

// MARK: - Toast Examples

public enum JetToastExamples {
    public struct Config {
        public let message: String
        public let type: ToastType
        public let duration: TimeInterval

        public init(message: String, type: ToastType, duration: TimeInterval = 2.0) {
            self.message = message
            self.type = type
            self.duration = duration
        }
    }

    public static let successSaved = Config(message: "Changes saved", type: .success)
    public static let errorNetwork = Config(message: "Network unavailable. Check your connection.", type: .error, duration: 3.0)
    public static let warningStorage = Config(message: "Storage almost full", type: .warning)
    public static let infoUpdate = Config(message: "A new update is available", type: .info)

    public static let all: [Config] = [successSaved, errorNetwork, warningStorage, infoUpdate]
}

// MARK: - Custom Alert Examples

public enum JetAlertExamples {
    public struct Config {
        public let title: String
        public let message: String
        public let confirmTitle: String
        public let cancelTitle: String
        public let isDestructive: Bool

        public init(
            title: String,
            message: String,
            confirmTitle: String = "Confirm",
            cancelTitle: String = "Cancel",
            isDestructive: Bool = false
        ) {
            self.title = title
            self.message = message
            self.confirmTitle = confirmTitle
            self.cancelTitle = cancelTitle
            self.isDestructive = isDestructive
        }
    }

    public static let deleteConfirm = Config(
        title: "Delete Item",
        message: "This action cannot be undone.",
        confirmTitle: "Delete",
        cancelTitle: "Cancel",
        isDestructive: true
    )
    public static let logoutConfirm = Config(
        title: "Sign Out",
        message: "Are you sure you want to sign out?",
        confirmTitle: "Sign Out",
        cancelTitle: "Stay"
    )
    public static let purchaseConfirm = Config(
        title: "Complete Purchase",
        message: "You'll be charged after the free trial ends.",
        confirmTitle: "Continue",
        cancelTitle: "Maybe Later"
    )

    public static let all: [Config] = [deleteConfirm, logoutConfirm, purchaseConfirm]
}

// MARK: - Image Cache Examples

public enum JetImageExamples {
    public static let sampleURLs: [URL] = [
        URL(string: "https://picsum.photos/seed/jet1/200/200")!,
        URL(string: "https://picsum.photos/seed/jet2/200/200")!,
        URL(string: "https://picsum.photos/seed/jet3/200/200")!,
    ]

    public static let avatarURL = URL(string: "https://picsum.photos/seed/avatar/80/80")!
    public static let bannerURL = URL(string: "https://picsum.photos/seed/banner/800/300")!
}
