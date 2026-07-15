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
    private let wrapsInNavigationStack: Bool
    
    public init(
        configuration: Configuration,
        wrapsInNavigationStack: Bool = true
    ) {
        self.configuration = configuration
        self.wrapsInNavigationStack = wrapsInNavigationStack
    }
    
    @ViewBuilder
    public var body: some View {
        if wrapsInNavigationStack {
            NavigationStack {
                configuredContent
            }
        } else {
            configuredContent
        }
    }

    private var configuredContent: some View {
        contentView
            .background(configuration.theme.backgroundColor)
            .toolbar {
                toolbarContent
            }
            .navigationTitle(navigationTitleText)
            .navigationBarTitleDisplayMode(navigationBarDisplayMode)
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
            // Top custom content
            if let topContentView = configuration.topContentView {
                topContentView
                    .padding(.top, 24)
            }

            // Membership Card
            if configuration.membershipCard.isEnabled {
                JetMembershipCardView(
                    configuration: configuration.membershipCard,
                    theme: configuration.theme
                )
                .padding(.top, configuration.topContentView == nil ? 24 : 0)
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
                    
                    // Top custom content
                    if let topContentView = configuration.topContentView {
                        topContentView
                            .padding(.horizontal, 20)
                    }

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
            // Top custom content
            if let topContentView = configuration.topContentView {
                Section {
                    topContentView
                }
            }

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
            // Top custom content
            if let topContentView = configuration.topContentView {
                Section {
                    topContentView
                }
            }

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
        topContentView: AnyView? = nil,
        sections: [JetSettingSection],
        footer: JetSettingsFooterConfiguration = .disabled,
        customBottomView: AnyView? = nil,
        wrapsInNavigationStack: Bool = true,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.configuration = JetSettingsConfiguration(
            title: title,
            theme: theme,
            rowStyle: rowStyle,
            navigationStyle: navigationStyle,
            membershipCard: membershipCard,
            topContentView: topContentView,
            sections: sections,
            footer: footer,
            customBottomView: customBottomView,
            onDismiss: onDismiss
        )
        self.wrapsInNavigationStack = wrapsInNavigationStack
    }
}
