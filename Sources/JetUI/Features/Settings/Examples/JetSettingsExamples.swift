//
//  JetSettingsExamples.swift
//  JetUI
//
//  Example JetSettingsConfiguration presets that host apps can copy and adapt.
//

import SwiftUI

// MARK: - Settings Configuration Presets

public extension JetSettingsConfiguration {
    /// Dark-themed settings page — suited for camera / photo apps.
    static func exampleDark(onDismiss: @escaping () -> Void = {}) -> JetSettingsConfiguration {
        JetSettingsConfiguration(
            title: "Settings",
            theme: .dark,
            rowStyle: .darkCard,
            navigationStyle: .dismissButton,
            membershipCard: JetMembershipCardConfiguration(
                isEnabled: true,
                style: .gradient(
                    colors: [Color(red: 0.40, green: 0.10, blue: 0.80), Color(red: 0.90, green: 0.40, blue: 0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                title: "Go Pro",
                subtitle: "Unlock all features",
                buttonTitle: "Upgrade",
                activatedTitle: "Pro Active",
                onTap: {},
                isSubscribed: { false }
            ),
            sections: [
                JetSettingSection(
                    header: "General",
                    items: [
                        JetSettingItem(icon: .system("bell.fill"), title: "Notifications", action: {}),
                        JetSettingItem(icon: .system("globe"), title: "Language", detail: "English", action: {}),
                    ]
                ),
                JetSettingSection(
                    header: "Support",
                    items: [
                        JetSettingItem(icon: .system("star.fill"), title: "Rate the App", action: {}),
                        JetSettingItem(icon: .system("envelope.fill"), title: "Contact Us", action: {}),
                    ]
                ),
                JetSettingSection(
                    header: "Legal",
                    items: [
                        JetSettingItem(icon: .system("hand.raised.fill"), title: "Privacy Policy", action: {}),
                        JetSettingItem(icon: .system("doc.text.fill"), title: "Terms of Use", action: {}),
                    ]
                ),
            ],
            footer: JetSettingsFooterConfiguration(
                isEnabled: true,
                appName: "ExampleApp",
                companyName: "Acme Corp",
                version: "2.0.0",
                build: "100"
            ),
            onDismiss: onDismiss
        )
    }

    /// Light-themed settings — suited for productivity / utility apps.
    static func exampleLight(onDismiss: @escaping () -> Void = {}) -> JetSettingsConfiguration {
        JetSettingsConfiguration(
            title: "Settings",
            theme: .light,
            rowStyle: .standard,
            navigationStyle: .doneButton,
            sections: [
                JetSettingSection(
                    header: "Account",
                    items: [
                        JetSettingItem(icon: .system("person.crop.circle"), title: "Profile", action: {}),
                        JetSettingItem(icon: .system("key.fill"), title: "Change Password", action: {}),
                    ]
                ),
                JetSettingSection(
                    items: [
                        JetSettingItem(icon: .system("arrow.right.square.fill"), title: "Sign Out", showChevron: false, action: {}),
                    ]
                ),
            ],
            footer: JetSettingsFooterConfiguration(
                isEnabled: true,
                appName: "ExampleApp",
                companyName: "Acme Corp",
                version: "2.0.0",
                build: "100"
            ),
            onDismiss: onDismiss
        )
    }
}
