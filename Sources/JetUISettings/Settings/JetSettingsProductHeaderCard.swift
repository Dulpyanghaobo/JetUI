//
//  JetSettingsProductHeaderCard.swift
//  JetUI
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public struct JetSettingsProductHeaderCard: View {
    public let appIcon: JetSettingIcon
    public let title: String
    public let subtitle: String
    public let description: String
    public let versionText: String?
    public let actionTitle: String?
    public let action: (() -> Void)?

    public init(
        appIcon: JetSettingIcon,
        title: String,
        subtitle: String,
        description: String,
        versionText: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.appIcon = appIcon
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.versionText = versionText
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                productIcon

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Text(subtitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer(minLength: 12)
            }

            Text(description)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                if let versionText, !versionText.isEmpty {
                    Text(versionText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                if let actionTitle, !actionTitle.isEmpty, let action {
                    Button(actionTitle, action: action)
                        .font(.system(size: 13, weight: .semibold))
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardBackground)
        )
    }

    private var cardBackground: Color {
        #if canImport(UIKit)
        Color(UIColor.secondarySystemGroupedBackground)
        #else
        Color.gray.opacity(0.12)
        #endif
    }

    @ViewBuilder
    private var productIcon: some View {
        switch appIcon {
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 58, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.accentColor.gradient)
                )

        case .image(let name):
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

        case .custom(let view):
            view
                .frame(width: 58, height: 58)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

        case .none:
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.accentColor.opacity(0.14))
                .frame(width: 58, height: 58)
                .overlay(
                    Image(systemName: "app.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                )
        }
    }
}
