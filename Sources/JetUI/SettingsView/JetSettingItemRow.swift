//
//  JetSettingItemRow.swift
//  JetUI
//
//  Created by i564407 on 2/9/26.
//

import SwiftUI

// MARK: - Setting Item Row View
/// 可配置样式的设置行组件
public struct JetSettingItemRow: View {
    let item: JetSettingItem
    let style: JetSettingRowStyle
    let theme: JetSettingsTheme
    
    public init(
        item: JetSettingItem,
        style: JetSettingRowStyle = .standard,
        theme: JetSettingsTheme = .standard
    ) {
        self.item = item
        self.style = style
        self.theme = theme
    }
    
    public var body: some View {
        Button(action: item.action) {
            content
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var content: some View {
        switch style {
        case .darkCard:
            darkCardStyle
        case .lightCard:
            lightCardStyle
        case .standard:
            standardStyle
        case .custom(let rowHeight, let cornerRadius, let backgroundColor, let borderColor):
            customStyle(rowHeight: rowHeight, cornerRadius: cornerRadius, backgroundColor: backgroundColor, borderColor: borderColor)
        }
    }
    
    // MARK: - Dark Card Style (TimeProof/WatermarkCamera)
    private var darkCardStyle: some View {
        HStack(spacing: 16) {
            iconView(size: 40)
            
            Text(item.title)
                .foregroundColor(theme.primaryTextColor)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            if let detail = item.detail {
                Text(detail)
                    .foregroundColor(theme.secondaryTextColor)
                    .font(.system(size: 14))
            }
            
            if item.showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(theme.secondaryTextColor)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 72)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
    
    // MARK: - Light Card Style (AlarmApp)
    private var lightCardStyle: some View {
        HStack(spacing: 12) {
            iconView(size: 36, showBackground: true)
            
            Text(item.title)
                .foregroundColor(theme.primaryTextColor)
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let detail = item.detail {
                Text(detail)
                    .foregroundColor(theme.secondaryTextColor)
                    .font(.system(size: 16, weight: .regular))
            }
            
            if item.showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
        .contentShape(Rectangle())
        .frame(minHeight: 56)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Standard Style (DocumentScan)
    private var standardStyle: some View {
        HStack {
            iconView(size: 24)
            
            Text(item.title)
                .font(.system(size: 17))
                .foregroundColor(theme.primaryTextColor)
            
            Spacer()
            
            if let detail = item.detail {
                Text(detail)
                    .foregroundColor(theme.secondaryTextColor)
                    .font(.system(size: 15))
            }
            
            if item.showChevron {
                Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .foregroundStyle(theme.secondaryTextColor)
                    .fontWeight(.semibold)
            }
        }
    }
    
    // MARK: - Custom Style
    private func customStyle(rowHeight: CGFloat, cornerRadius: CGFloat, backgroundColor: Color, borderColor: Color?) -> some View {
        HStack(spacing: 16) {
            iconView(size: 24)
            
            Text(item.title)
                .foregroundColor(theme.primaryTextColor)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            if let detail = item.detail {
                Text(detail)
                    .foregroundColor(theme.secondaryTextColor)
                    .font(.system(size: 14))
            }
            
            if item.showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(theme.secondaryTextColor)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: rowHeight)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(backgroundColor)
                .overlay(
                    Group {
                        if let borderColor = borderColor {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(borderColor, lineWidth: 0.5)
                        }
                    }
                )
        )
    }
    
    // MARK: - Icon View
    @ViewBuilder
    private func iconView(size: CGFloat, showBackground: Bool = false) -> some View {
        switch item.icon {
        case .system(let name):
            if showBackground {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                        .frame(width: size, height: size)
                    Image(systemName: name)
                        .font(.system(size: size * 0.47, weight: .semibold))
                        .foregroundColor(theme.primaryTextColor)
                }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: size, height: size)
                    Image(systemName: name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.5, height: size * 0.5)
                        .foregroundColor(theme.primaryTextColor)
                }
            }
            
        case .image(let name):
            if showBackground {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                        .frame(width: size, height: size)
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.6, height: size * 0.6)
                }
            } else {
                Image(name)
                    .resizable()
                    .frame(width: size, height: size)
            }
            
        case .custom(let view):
            view
                .frame(width: size, height: size)
            
        case .none:
            EmptyView()
        }
    }
}

// MARK: - Preview
#if DEBUG
struct JetSettingItemRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            // Dark Card Style
            JetSettingItemRow(
                item: JetSettingItem(
                    icon: .system("star.fill"),
                    title: "Rate Us",
                    action: {}
                ),
                style: .darkCard,
                theme: .dark
            )
            
            // Light Card Style
            JetSettingItemRow(
                item: JetSettingItem(
                    icon: .system("questionmark.app.fill"),
                    title: "Help & Support",
                    detail: "v1.0.2",
                    action: {}
                ),
                style: .lightCard,
                theme: .light
            )
            
            // Standard Style
            JetSettingItemRow(
                item: JetSettingItem(
                    icon: .system("envelope"),
                    title: "Feedback",
                    action: {}
                ),
                style: .standard,
                theme: .standard
            )
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
#endif