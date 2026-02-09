//
//  JetSettingsConfiguration.swift
//  JetUI
//
//  Created by i564407 on 2/9/26.
//

import SwiftUI

// MARK: - Settings Theme
/// 设置页面的主题配置
public struct JetSettingsTheme {
    /// 背景颜色
    public let backgroundColor: Color
    /// 主要文字颜色
    public let primaryTextColor: Color
    /// 次要文字颜色
    public let secondaryTextColor: Color
    /// Section 标题颜色
    public let sectionHeaderColor: Color
    /// 分隔线颜色
    public let separatorColor: Color
    /// 强调色
    public let accentColor: Color
    
    public init(
        backgroundColor: Color = Color(.systemGroupedBackground),
        primaryTextColor: Color = .primary,
        secondaryTextColor: Color = .secondary,
        sectionHeaderColor: Color = .secondary,
        separatorColor: Color = Color(.separator),
        accentColor: Color = .blue
    ) {
        self.backgroundColor = backgroundColor
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.sectionHeaderColor = sectionHeaderColor
        self.separatorColor = separatorColor
        self.accentColor = accentColor
    }
    
    // MARK: - Presets
    
    /// 深色主题（适用于 TimeProof, WatermarkCamera）
    public static let dark = JetSettingsTheme(
        backgroundColor: .black,
        primaryTextColor: .white,
        secondaryTextColor: .gray,
        sectionHeaderColor: .white,
        separatorColor: Color.white.opacity(0.2),
        accentColor: .white
    )
    
    /// 浅色主题（适用于 AlarmApp）
    public static let light = JetSettingsTheme(
        backgroundColor: Color(.systemGroupedBackground),
        primaryTextColor: .primary,
        secondaryTextColor: .secondary,
        sectionHeaderColor: .secondary,
        separatorColor: Color(.separator),
        accentColor: .blue
    )
    
    /// 标准主题（适用于 DocumentScan）
    public static let standard = JetSettingsTheme(
        backgroundColor: Color(.systemBackground),
        primaryTextColor: .primary,
        secondaryTextColor: .secondary,
        sectionHeaderColor: .secondary,
        separatorColor: Color(.separator),
        accentColor: .blue
    )
}

// MARK: - Setting Row Style
/// 设置行的样式枚举
public enum JetSettingRowStyle {
    /// 深色卡片样式（圆角背景）
    case darkCard
    /// 浅色卡片样式
    case lightCard
    /// 标准列表样式
    case standard
    /// 自定义样式
    case custom(rowHeight: CGFloat, cornerRadius: CGFloat, backgroundColor: Color, borderColor: Color?)
}

// MARK: - Navigation Style
/// 导航栏样式
public enum JetSettingsNavigationStyle {
    /// 左上角 X 按钮关闭
    case dismissButton
    /// 左上角圆形关闭按钮
    case circleCloseButton
    /// 右上角 Done 按钮
    case doneButton
    /// 无导航按钮
    case none
}

// MARK: - Setting Item Icon
/// 设置项图标类型
public enum JetSettingIcon: Equatable {
    /// 系统 SF Symbol 图标
    case system(String)
    /// 本地图片资源
    case image(String)
    /// 自定义视图
    case custom(AnyView)
    /// 无图标
    case none
    
    public static func == (lhs: JetSettingIcon, rhs: JetSettingIcon) -> Bool {
        switch (lhs, rhs) {
        case (.system(let l), .system(let r)): return l == r
        case (.image(let l), .image(let r)): return l == r
        case (.none, .none): return true
        default: return false
        }
    }
}

// MARK: - Setting Item
/// 单个设置项数据模型
public struct JetSettingItem: Identifiable {
    public let id = UUID()
    /// 图标
    public let icon: JetSettingIcon
    /// 标题
    public let title: String
    /// 右侧详情文字（可选）
    public let detail: String?
    /// 是否显示箭头
    public let showChevron: Bool
    /// 点击动作
    public let action: () -> Void
    
    public init(
        icon: JetSettingIcon = .none,
        title: String,
        detail: String? = nil,
        showChevron: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.detail = detail
        self.showChevron = showChevron
        self.action = action
    }
}

// MARK: - Setting Section
/// 设置分组
public struct JetSettingSection: Identifiable {
    public let id = UUID()
    /// 分组标题（可选）
    public let header: String?
    /// 分组底部说明（可选）
    public let footer: String?
    /// 分组内的设置项
    public let items: [JetSettingItem]
    
    public init(
        header: String? = nil,
        footer: String? = nil,
        items: [JetSettingItem]
    ) {
        self.header = header
        self.footer = footer
        self.items = items
    }
}

// MARK: - Membership Card Configuration
/// 会员卡片配置
public struct JetMembershipCardConfiguration {
    /// 是否显示会员卡片
    public let isEnabled: Bool
    /// 卡片样式
    public let style: CardStyle
    /// 标题
    public let title: String
    /// 副标题
    public let subtitle: String
    /// 按钮文字
    public let buttonTitle: String
    /// 已激活时显示的文字
    public let activatedTitle: String
    /// 点击动作
    public let onTap: () -> Void
    /// 是否已订阅（用于显示不同状态）
    public let isSubscribed: () -> Bool
    
    public enum CardStyle {
        /// 渐变色背景
        case gradient(colors: [Color], startPoint: UnitPoint, endPoint: UnitPoint)
        /// 图片背景
        case image(String)
        /// 纯色背景
        case solid(Color)
        /// 自定义视图
        case custom(AnyView)
    }
    
    public init(
        isEnabled: Bool = true,
        style: CardStyle = .gradient(colors: [.purple, .orange], startPoint: .top, endPoint: .bottom),
        title: String = "Pro",
        subtitle: String = "Unlock all premium features",
        buttonTitle: String = "Activate",
        activatedTitle: String = "Activated",
        onTap: @escaping () -> Void = {},
        isSubscribed: @escaping () -> Bool = { false }
    ) {
        self.isEnabled = isEnabled
        self.style = style
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.activatedTitle = activatedTitle
        self.onTap = onTap
        self.isSubscribed = isSubscribed
    }
    
    public static let disabled = JetMembershipCardConfiguration(isEnabled: false, onTap: {})
}

// MARK: - Footer Configuration
/// 底部信息配置
public struct JetSettingsFooterConfiguration {
    /// 是否显示
    public let isEnabled: Bool
    /// App 名称
    public let appName: String
    /// 公司/开发者名称
    public let companyName: String
    /// 版本号
    public let version: String
    /// 构建号
    public let build: String
    
    public init(
        isEnabled: Bool = false,
        appName: String = "",
        companyName: String = "",
        version: String = "",
        build: String = ""
    ) {
        self.isEnabled = isEnabled
        self.appName = appName
        self.companyName = companyName
        self.version = version
        self.build = build
    }
    
    public static let disabled = JetSettingsFooterConfiguration()
    
    /// 从 Bundle 自动获取版本信息
    public static func fromBundle(appName: String, companyName: String = "") -> JetSettingsFooterConfiguration {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return JetSettingsFooterConfiguration(
            isEnabled: true,
            appName: appName,
            companyName: companyName,
            version: version,
            build: build
        )
    }
}

// MARK: - Settings Configuration Protocol
/// 设置页面配置协议
public protocol JetSettingsConfigurationProtocol {
    /// 页面标题
    var title: String { get }
    /// 主题配置
    var theme: JetSettingsTheme { get }
    /// 行样式
    var rowStyle: JetSettingRowStyle { get }
    /// 导航样式
    var navigationStyle: JetSettingsNavigationStyle { get }
    /// 会员卡片配置
    var membershipCard: JetMembershipCardConfiguration { get }
    /// 设置分组列表
    var sections: [JetSettingSection] { get }
    /// 底部信息配置
    var footer: JetSettingsFooterConfiguration { get }
    /// 自定义底部视图（如推荐应用）
    var customBottomView: AnyView? { get }
    /// 关闭回调
    var onDismiss: () -> Void { get }
}

// MARK: - Default Implementation
public extension JetSettingsConfigurationProtocol {
    var title: String { "Settings" }
    var theme: JetSettingsTheme { .standard }
    var rowStyle: JetSettingRowStyle { .standard }
    var navigationStyle: JetSettingsNavigationStyle { .doneButton }
    var membershipCard: JetMembershipCardConfiguration { .disabled }
    var footer: JetSettingsFooterConfiguration { .disabled }
    var customBottomView: AnyView? { nil }
}

// MARK: - Concrete Configuration
/// 具体的设置配置实现
public struct JetSettingsConfiguration: JetSettingsConfigurationProtocol {
    public var title: String
    public var theme: JetSettingsTheme
    public var rowStyle: JetSettingRowStyle
    public var navigationStyle: JetSettingsNavigationStyle
    public var membershipCard: JetMembershipCardConfiguration
    public var sections: [JetSettingSection]
    public var footer: JetSettingsFooterConfiguration
    public var customBottomView: AnyView?
    public var onDismiss: () -> Void
    
    public init(
        title: String = "Settings",
        theme: JetSettingsTheme = .standard,
        rowStyle: JetSettingRowStyle = .standard,
        navigationStyle: JetSettingsNavigationStyle = .doneButton,
        membershipCard: JetMembershipCardConfiguration = .disabled,
        sections: [JetSettingSection] = [],
        footer: JetSettingsFooterConfiguration = .disabled,
        customBottomView: AnyView? = nil,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.title = title
        self.theme = theme
        self.rowStyle = rowStyle
        self.navigationStyle = navigationStyle
        self.membershipCard = membershipCard
        self.sections = sections
        self.footer = footer
        self.customBottomView = customBottomView
        self.onDismiss = onDismiss
    }
}
