//
//  JetSettingsView.swift
//  JetUI
//
//  Created by i564407 on 2/9/26.
//

import SwiftUI

// MARK: - Jet Settings View
/// 可配置样式的设置页面组件
/// 支持多种主题风格，通过策略模式实现UI差异化
public struct JetSettingsView<Configuration: JetSettingsConfigurationProtocol>: View {
    @Environment(\.dismiss) private var dismiss
    
    let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public var body: some View {
        NavigationStack {
            contentView
                .background(configuration.theme.backgroundColor)
                .toolbar {
                    toolbarContent
                }
                .navigationTitle(navigationTitleText)
                .navigationBarTitleDisplayMode(navigationBarDisplayMode)
        }
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        switch configuration.rowStyle {
        case .darkCard:
            darkCardContent
        case .lightCard:
            lightCardContent
        case .standard:
            standardContent
        case .custom:
            customContent
        }
    }
    
    // MARK: - Navigation Title
    private var navigationTitleText: String {
        switch configuration.navigationStyle {
        case .dismissButton, .circleCloseButton:
            return ""
        default:
            return configuration.title
        }
    }
    
    private var navigationBarDisplayMode: NavigationBarItem.TitleDisplayMode {
        switch configuration.navigationStyle {
        case .dismissButton, .circleCloseButton:
            return .inline
        default:
            return .inline
        }
    }
    
    // MARK: - Dark Card Content (TimeProof/WatermarkCamera Style)
    private var darkCardContent: some View {
        VStack(spacing: 24) {
            // Membership Card
            if configuration.membershipCard.isEnabled {
                JetMembershipCardView(
                    configuration: configuration.membershipCard,
                    theme: configuration.theme
                )
                .padding(.top, 24)
            }
            
            List {
                ForEach(configuration.sections) { section in
                    Section(header: sectionHeader(section.header)) {
                        ForEach(section.items) { item in
                            JetSettingItemRow(
                                item: item,
                                style: configuration.rowStyle,
                                theme: configuration.theme
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .padding(.bottom, 16)
                        }
                    }
                }
                
                // Custom Bottom View (如 JetRecommendationsView)
                if let customView = configuration.customBottomView {
                    Section {
                        customView
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Light Card Content (AlarmApp Style)
    private var lightCardContent: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text(configuration.title)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(configuration.theme.primaryTextColor)
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                    
                    // Membership Card
                    if configuration.membershipCard.isEnabled {
                        JetMembershipCardView(
                            configuration: configuration.membershipCard,
                            theme: configuration.theme
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Sections
                    ForEach(configuration.sections) { section in
                        VStack(spacing: 0) {
                            // Section Header
                            if let header = section.header {
                                Text(header)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(configuration.theme.secondaryTextColor)
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 8)
                            }
                            
                            // Group Card
                            JetSettingsGroupCard(theme: configuration.theme) {
                                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                                    JetSettingItemRow(
                                        item: item,
                                        style: configuration.rowStyle,
                                        theme: configuration.theme
                                    )
                                    
                                    if index < section.items.count - 1 {
                                        Divider()
                                            .padding(.leading, 68)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Section Footer
                            if let footer = section.footer {
                                Text(footer)
                                    .font(.system(size: 14))
                                    .foregroundColor(configuration.theme.secondaryTextColor)
                                    .padding(.horizontal, 28)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    
                    // Custom Bottom View
                    if let customView = configuration.customBottomView {
                        customView
                            .padding(.horizontal, 20)
                    }
                    
                    // Footer
                    if configuration.footer.isEnabled {
                        footerView
                    }
                }
            }
            
            // Close Button (for circleCloseButton style)
            if case .circleCloseButton = configuration.navigationStyle {
                circleCloseButton
            }
        }
        .ignoresSafeArea(.container, edges: .top)
    }
    
    // MARK: - Standard Content (DocumentScan Style)
    private var standardContent: some View {
        List {
            // Membership Card
            if configuration.membershipCard.isEnabled {
                Section {
                    JetMembershipCardView(
                        configuration: configuration.membershipCard,
                        theme: configuration.theme
                    )
                }
            }
            
            // Sections
            ForEach(configuration.sections) { section in
                Section(header: sectionHeaderText(section.header), footer: sectionFooterText(section.footer)) {
                    ForEach(section.items) { item in
                        JetSettingItemRow(
                            item: item,
                            style: configuration.rowStyle,
                            theme: configuration.theme
                        )
                    }
                }
            }
            
            // Custom Bottom View
            if let customView = configuration.customBottomView {
                Section {
                    customView
                }
            }
        }
    }
    
    // MARK: - Custom Content
    private var customContent: some View {
        List {
            // Membership Card
            if configuration.membershipCard.isEnabled {
                Section {
                    JetMembershipCardView(
                        configuration: configuration.membershipCard,
                        theme: configuration.theme
                    )
                }
            }
            
            // Sections
            ForEach(configuration.sections) { section in
                Section(header: sectionHeaderText(section.header)) {
                    ForEach(section.items) { item in
                        JetSettingItemRow(
                            item: item,
                            style: configuration.rowStyle,
                            theme: configuration.theme
                        )
                    }
                }
            }
            
            // Custom Bottom View
            if let customView = configuration.customBottomView {
                Section {
                    customView
                }
            }
        }
    }
    
    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        switch configuration.navigationStyle {
        case .dismissButton:
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismissView() }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(configuration.theme.primaryTextColor)
                }
                .padding(8)
            }
            
        case .doneButton:
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismissView()
                }
                .fontWeight(.semibold)
            }
            
        case .circleCloseButton, .none:
            ToolbarItem(placement: .topBarLeading) {
                EmptyView()
            }
        }
    }
    
    // MARK: - Circle Close Button
    private var circleCloseButton: some View {
        Button(action: { dismissView() }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(configuration.theme.primaryTextColor)
            }
            .padding(.top, 8)
            .padding(.leading, 8)
        }
    }
    
    // MARK: - Section Header
    @ViewBuilder
    private func sectionHeader(_ title: String?) -> some View {
        if let title = title {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(configuration.theme.sectionHeaderColor)
                .padding(.bottom, 4)
        }
    }
    
    private func sectionHeaderText(_ title: String?) -> Text? {
        guard let title = title else { return nil }
        return Text(title)
    }
    
    private func sectionFooterText(_ text: String?) -> Text? {
        guard let text = text else { return nil }
        return Text(text)
    }
    
    // MARK: - Footer View
    private var footerView: some View {
        VStack(spacing: 4) {
            Text("\(configuration.footer.appName) by \(configuration.footer.companyName)")
                .font(.system(size: 13))
                .foregroundColor(configuration.theme.secondaryTextColor)
            Text("Version \(configuration.footer.version) (\(configuration.footer.build))")
                .font(.system(size: 13))
                .foregroundColor(configuration.theme.secondaryTextColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
    
    // MARK: - Dismiss
    private func dismissView() {
        configuration.onDismiss()
        dismiss()
    }
}

// MARK: - Settings Group Card
/// 分组卡片容器（用于 lightCard 样式）
public struct JetSettingsGroupCard<Content: View>: View {
    let theme: JetSettingsTheme
    @ViewBuilder var content: Content
    
    public init(theme: JetSettingsTheme = .light, @ViewBuilder content: () -> Content) {
        self.theme = theme
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.primary.opacity(0.06), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
    }
}

// MARK: - Convenience Initializer
public extension JetSettingsView where Configuration == JetSettingsConfiguration {
    /// 便捷初始化方法
    init(
        title: String = "Settings",
        theme: JetSettingsTheme = .standard,
        rowStyle: JetSettingRowStyle = .standard,
        navigationStyle: JetSettingsNavigationStyle = .doneButton,
        membershipCard: JetMembershipCardConfiguration = .disabled,
        sections: [JetSettingSection],
        footer: JetSettingsFooterConfiguration = .disabled,
        customBottomView: AnyView? = nil,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.configuration = JetSettingsConfiguration(
            title: title,
            theme: theme,
            rowStyle: rowStyle,
            navigationStyle: navigationStyle,
            membershipCard: membershipCard,
            sections: sections,
            footer: footer,
            customBottomView: customBottomView,
            onDismiss: onDismiss
        )
    }
}

// MARK: - Preview
#if DEBUG
struct JetSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Dark Card Style Preview
        JetSettingsView(
            title: "Settings",
            theme: .dark,
            rowStyle: .darkCard,
            navigationStyle: .dismissButton,
            sections: [
                JetSettingSection(
                    header: "Settings",
                    items: [
                        JetSettingItem(icon: .system("creditcard"), title: "Restore Purchase", action: {}),
                        JetSettingItem(icon: .system("square.and.arrow.up"), title: "Share to Friends", action: {}),
                        JetSettingItem(icon: .system("star.fill"), title: "Rate Us", action: {}),
                        JetSettingItem(icon: .system("doc.text"), title: "Terms of Use", action: {}),
                        JetSettingItem(icon: .system("lock.shield"), title: "Privacy Policy", action: {}),
                        JetSettingItem(icon: .system("envelope"), title: "Feedback", action: {})
                    ]
                )
            ]
        )
        .previewDisplayName("Dark Card Style")
        
        // Light Card Style Preview
        JetSettingsView(
            title: "Settings",
            theme: .light,
            rowStyle: .lightCard,
            navigationStyle: .circleCloseButton,
            membershipCard: JetMembershipCardConfiguration(
                isEnabled: true,
                style: .gradient(
                    colors: [Color.purple, Color.orange],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                title: "Awake Pro",
                subtitle: "Upgrade for all features",
                onTap: {}
            ),
            sections: [
                JetSettingSection(
                    items: [
                        JetSettingItem(icon: .system("questionmark.app.fill"), title: "Help & Support", action: {}),
                        JetSettingItem(icon: .system("sparkles"), title: "What's New", detail: "v1.0.2", action: {}),
                        JetSettingItem(icon: .system("star.fill"), title: "Write a Review", action: {})
                    ]
                )
            ],
            footer: .fromBundle(appName: "Awake", companyName: "unorderly GmbH")
        )
        .previewDisplayName("Light Card Style")
        
        // Standard Style Preview
        JetSettingsView(
            title: "Settings",
            theme: .standard,
            rowStyle: .standard,
            navigationStyle: .doneButton,
            membershipCard: JetMembershipCardConfiguration(
                isEnabled: true,
                style: .solid(Color(.secondarySystemBackground)),
                title: "Subscription Membership",
                subtitle: "",
                onTap: {}
            ),
            sections: [
                JetSettingSection(
                    items: [
                        JetSettingItem(icon: .image("icon_support"), title: "Help & Support", action: {}),
                        JetSettingItem(icon: .image("icon_privacy"), title: "Privacy Policy", action: {}),
                        JetSettingItem(icon: .image("icon_terms"), title: "Terms of Use", action: {})
                    ]
                )
            ]
        )
        .previewDisplayName("Standard Style")
    }
}
#endif
