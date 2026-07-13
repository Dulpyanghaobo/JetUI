//
//  JetRecommendationsView.swift
//  JetUI
//
//  Created by i564407 on 2/8/26.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public enum JetRecommendationsStyle: Equatable {
    case automatic
    case iconCarousel
    case sectionedRows
}

public struct JetRecommendationsAppearance {
    public var titleColor: Color?
    public var containerBackgroundColor: Color?
    public var rowBackgroundColor: Color?
    public var separatorColor: Color?
    public var primaryTextColor: Color?
    public var secondaryTextColor: Color?
    public var actionTextColor: Color?
    public var actionBackgroundColor: Color?
    public var iconBorderColor: Color?
    public var cornerRadius: CGFloat?
    public var rowCornerRadius: CGFloat?

    public init(
        titleColor: Color? = nil,
        containerBackgroundColor: Color? = nil,
        rowBackgroundColor: Color? = nil,
        separatorColor: Color? = nil,
        primaryTextColor: Color? = nil,
        secondaryTextColor: Color? = nil,
        actionTextColor: Color? = nil,
        actionBackgroundColor: Color? = nil,
        iconBorderColor: Color? = nil,
        cornerRadius: CGFloat? = nil,
        rowCornerRadius: CGFloat? = nil
    ) {
        self.titleColor = titleColor
        self.containerBackgroundColor = containerBackgroundColor
        self.rowBackgroundColor = rowBackgroundColor
        self.separatorColor = separatorColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.actionTextColor = actionTextColor
        self.actionBackgroundColor = actionBackgroundColor
        self.iconBorderColor = iconBorderColor
        self.cornerRadius = cornerRadius
        self.rowCornerRadius = rowCornerRadius
    }

    public static let automatic = JetRecommendationsAppearance()

    public static var light: JetRecommendationsAppearance {
        JetRecommendationsAppearance(
            titleColor: .secondary,
            containerBackgroundColor: .jetSecondaryGroupedBackground,
            rowBackgroundColor: .clear,
            separatorColor: .jetSeparator.opacity(0.35),
            primaryTextColor: .primary,
            secondaryTextColor: .secondary,
            actionTextColor: .white,
            actionBackgroundColor: .accentColor,
            iconBorderColor: Color.black.opacity(0.06),
            cornerRadius: 12,
            rowCornerRadius: 10
        )
    }

    public static var dark: JetRecommendationsAppearance {
        JetRecommendationsAppearance(
            titleColor: .white,
            containerBackgroundColor: Color.white.opacity(0.08),
            rowBackgroundColor: Color.white.opacity(0.04),
            separatorColor: Color.white.opacity(0.14),
            primaryTextColor: .white,
            secondaryTextColor: Color.white.opacity(0.7),
            actionTextColor: .white,
            actionBackgroundColor: Color.white.opacity(0.14),
            iconBorderColor: Color.white.opacity(0.12),
            cornerRadius: 16,
            rowCornerRadius: 12
        )
    }
}

public struct JetRecommendationsView: View {
    @Environment(\.colorScheme) private var colorScheme

    let items: [JetAppItem]
    let title: String
    let style: JetRecommendationsStyle
    let appearance: JetRecommendationsAppearance
    var onAppTap: ((JetAppItem) -> Void)?

    public init(
        title: String = "App Recommendations",
        items: [JetAppItem] = JetAppItem.companyApps,
        style: JetRecommendationsStyle = .automatic,
        appearance: JetRecommendationsAppearance = .automatic,
        onAppTap: ((JetAppItem) -> Void)? = nil
    ) {
        self.items = items
        self.title = title
        self.style = style
        self.appearance = appearance
        self.onAppTap = onAppTap
    }

    public var body: some View {
        let resolvedStyle = resolvedStyle
        let resolvedAppearance = appearance.resolved(for: colorScheme)

        VStack(alignment: .leading, spacing: 12) {
            if !title.isEmpty {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(resolvedAppearance.titleColor)
                    .padding(.leading, resolvedStyle == .sectionedRows ? 0 : 4)
            }

            switch resolvedStyle {
            case .iconCarousel:
                iconCarousel(appearance: resolvedAppearance)
            case .sectionedRows:
                sectionedRows(appearance: resolvedAppearance)
            case .automatic:
                EmptyView()
            }
        }
    }

    private var resolvedStyle: JetRecommendationsStyle {
        switch style {
        case .automatic:
            colorScheme == .dark ? .iconCarousel : .sectionedRows
        case .iconCarousel, .sectionedRows:
            style
        }
    }

    private func iconCarousel(appearance: ResolvedJetRecommendationsAppearance) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(items) { item in
                    RecommendationIconView(
                        item: item,
                        size: 80,
                        cornerRadius: 12,
                        borderColor: appearance.iconBorderColor
                    )
                    .onTapGesture {
                        handleTap(item)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(appearance.containerBackgroundColor)
        .cornerRadius(appearance.cornerRadius)
    }

    private func sectionedRows(appearance: ResolvedJetRecommendationsAppearance) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button {
                    handleTap(item)
                } label: {
                    HStack(spacing: 12) {
                        RecommendationIconView(
                            item: item,
                            size: 44,
                            cornerRadius: 10,
                            borderColor: appearance.iconBorderColor
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(appearance.primaryTextColor)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)

                            if let subtitle = item.subtitle, !subtitle.isEmpty {
                                Text(subtitle)
                                    .font(.footnote)
                                    .foregroundColor(appearance.secondaryTextColor)
                                    .lineLimit(2)
                            }
                        }

                        Spacer(minLength: 12)

                        if let actionTitle = item.actionTitle, !actionTitle.isEmpty {
                            Text(actionTitle)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(
                                    item.actionTextColorHex.map(Color.init(jetRecommendationsHex:))
                                        ?? appearance.actionTextColor
                                )
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule().fill(
                                        item.actionBackgroundColorHex.map(Color.init(jetRecommendationsHex:))
                                            ?? appearance.actionBackgroundColor
                                    )
                                )
                        } else if item.showsDisclosureIndicator {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(appearance.secondaryTextColor)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: appearance.rowCornerRadius, style: .continuous)
                            .fill(appearance.rowBackgroundColor)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < items.count - 1 {
                    Divider()
                        .background(appearance.separatorColor)
                        .padding(.leading, 70)
                }
            }
        }
        .background(appearance.containerBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: appearance.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: appearance.cornerRadius, style: .continuous)
                .stroke(appearance.separatorColor.opacity(0.6), lineWidth: 0.5)
        )
    }

    private func handleTap(_ item: JetAppItem) {
        onAppTap?(item)
        JetAppLauncher.open(item)
    }
}

private struct RecommendationIconView: View {
    let item: JetAppItem
    let size: CGFloat
    let cornerRadius: CGFloat
    let borderColor: Color

    var body: some View {
        iconView
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
    }

    @ViewBuilder
    private var iconView: some View {
        if let localName = item.localIconName {
            Image(localName, bundle: JetSettingsBundle.module)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let url = item.iconURL {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Color.gray
                        .overlay(
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.white)
                        )
                } else {
                    Color.gray.opacity(0.2)
                        .overlay(ProgressView())
                }
            }
        } else {
            Image(systemName: "questionmark.app")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(size * 0.16)
                .foregroundColor(.secondary)
                .background(Color.gray.opacity(0.16))
        }
    }
}

private struct ResolvedJetRecommendationsAppearance {
    let titleColor: Color
    let containerBackgroundColor: Color
    let rowBackgroundColor: Color
    let separatorColor: Color
    let primaryTextColor: Color
    let secondaryTextColor: Color
    let actionTextColor: Color
    let actionBackgroundColor: Color
    let iconBorderColor: Color
    let cornerRadius: CGFloat
    let rowCornerRadius: CGFloat
}

private extension JetRecommendationsAppearance {
    func resolved(for colorScheme: ColorScheme) -> ResolvedJetRecommendationsAppearance {
        let defaults = colorScheme == .dark ? JetRecommendationsAppearance.dark : JetRecommendationsAppearance.light

        return ResolvedJetRecommendationsAppearance(
            titleColor: titleColor ?? defaults.titleColor ?? .primary,
            containerBackgroundColor: containerBackgroundColor ?? defaults.containerBackgroundColor ?? .clear,
            rowBackgroundColor: rowBackgroundColor ?? defaults.rowBackgroundColor ?? .clear,
            separatorColor: separatorColor ?? defaults.separatorColor ?? .clear,
            primaryTextColor: primaryTextColor ?? defaults.primaryTextColor ?? .primary,
            secondaryTextColor: secondaryTextColor ?? defaults.secondaryTextColor ?? .secondary,
            actionTextColor: actionTextColor ?? defaults.actionTextColor ?? .white,
            actionBackgroundColor: actionBackgroundColor ?? defaults.actionBackgroundColor ?? .accentColor,
            iconBorderColor: iconBorderColor ?? defaults.iconBorderColor ?? .clear,
            cornerRadius: cornerRadius ?? defaults.cornerRadius ?? 16,
            rowCornerRadius: rowCornerRadius ?? defaults.rowCornerRadius ?? 12
        )
    }
}

private extension Color {
    init(jetRecommendationsHex hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    static var jetSecondaryGroupedBackground: Color {
        #if canImport(UIKit)
        Color(UIColor.secondarySystemGroupedBackground)
        #else
        Color.white
        #endif
    }

    static var jetSeparator: Color {
        #if canImport(UIKit)
        Color(UIColor.separator)
        #else
        Color.gray.opacity(0.4)
        #endif
    }
}

private enum JetSettingsBundle {
    static var module: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return .main
        #endif
    }
}
