//
//  JetRecommendationsSummaryRow.swift
//  JetUI
//

import SwiftUI

public struct JetRecommendationsSummaryRow: View {
    public let title: String
    public let subtitle: String
    public let items: [JetAppItem]
    public let actionTitle: String?
    public let action: () -> Void

    public init(
        title: String,
        subtitle: String,
        items: [JetAppItem],
        actionTitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                iconStack

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 12)

                if let actionTitle, !actionTitle.isEmpty {
                    Text(actionTitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var iconStack: some View {
        ZStack {
            ForEach(Array(items.prefix(3).enumerated()), id: \.element.id) { index, item in
                SummaryAppIcon(item: item)
                    .offset(x: CGFloat(index) * 16)
                    .zIndex(Double(3 - index))
            }
        }
        .frame(width: items.prefix(3).count > 1 ? 68 : 36, height: 36, alignment: .leading)
    }
}

private struct SummaryAppIcon: View {
    let item: JetAppItem

    var body: some View {
        iconView
            .frame(width: 36, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 2, y: 1)
    }

    @ViewBuilder
    private var iconView: some View {
        if let localName = item.localIconName {
            Image(localName, bundle: JetRecommendationsSummaryBundle.module)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let url = item.iconURL {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(Color.accentColor.opacity(0.14))
            .overlay(
                Image(systemName: "app.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
            )
    }
}

private enum JetRecommendationsSummaryBundle {
    static var module: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return .main
        #endif
    }
}
