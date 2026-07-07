//
//  JetSettingsPresets.swift
//  JetUI
//
//  Created by i564407 on 2/9/26.
//

import SwiftUI

// MARK: - Settings Presets
/// 预设的设置页面配置，对应四种不同的 App 风格

public extension JetSettingsConfiguration {
    
    // MARK: - TimeProof Style (Dark Theme)
    /// TimeProof 风格：深色主题，圆角卡片行，左上角X关闭按钮
    /// 适用于：TimeProof, WatermarkCamera 等深色主题 App
    static func timeProofStyle(
        sections: [JetSettingSection],
        customBottomView: AnyView? = nil,
        onDismiss: @escaping () -> Void = {}
    ) -> JetSettingsConfiguration {
        JetSettingsConfiguration(
            title: "Settings",
            theme: .dark,
            rowStyle: .darkCard,
            navigationStyle: .dismissButton,
            membershipCard: .disabled,
            sections: sections,
            footer: .disabled,
            customBottomView: customBottomView,
            onDismiss: onDismiss
        )
    }
    
    // MARK: - WatermarkCamera Style (Dark Theme with Membership)
    /// WatermarkCamera 风格：深色主题，带会员卡片
    /// 适用于：带订阅功能的深色主题 App
    static func watermarkCameraStyle(
        membershipCard: JetMembershipCardConfiguration,
        sections: [JetSettingSection],
        customBottomView: AnyView? = nil,
        onDismiss: @escaping () -> Void = {}
    ) -> JetSettingsConfiguration {
        JetSettingsConfiguration(
            title: "Settings",
            theme: .dark,
            rowStyle: .darkCard,
            navigationStyle: .dismissButton,
            membershipCard: membershipCard,
            sections: sections,
            footer: .disabled,
            customBottomView: customBottomView,
            onDismiss: onDismiss
        )
    }
    
    // MARK: - AlarmApp Style (Light Card Theme)
    /// AlarmApp 风格：浅色主题，卡片式分组，大标题，圆形关闭按钮
    /// 适用于：现代化浅色主题 App
    static func alarmAppStyle(
        title: String = "Settings",
        membershipCard: JetMembershipCardConfiguration = .disabled,
        sections: [JetSettingSection],
        footer: JetSettingsFooterConfiguration = .disabled,
        customBottomView: AnyView? = nil,
        onDismiss: @escaping () -> Void = {}
    ) -> JetSettingsConfiguration {
        JetSettingsConfiguration(
            title: title,
            theme: .light,
            rowStyle: .lightCard,
            navigationStyle: .circleCloseButton,
            membershipCard: membershipCard,
            sections: sections,
            footer: footer,
            customBottomView: customBottomView,
            onDismiss: onDismiss
        )
    }
    
    // MARK: - DocumentScan Style (Standard Theme)
    /// DocumentScan 风格：标准系统风格，导航栏样式，Done按钮
    /// 适用于：遵循系统设计规范的 App
    static func documentScanStyle(
        title: String = "Settings",
        membershipCard: JetMembershipCardConfiguration = .disabled,
        sections: [JetSettingSection],
        customBottomView: AnyView? = nil,
        onDismiss: @escaping () -> Void = {}
    ) -> JetSettingsConfiguration {
        JetSettingsConfiguration(
            title: title,
            theme: .standard,
            rowStyle: .standard,
            navigationStyle: .doneButton,
            membershipCard: membershipCard,
            sections: sections,
            footer: .disabled,
            customBottomView: customBottomView,
            onDismiss: onDismiss
        )
    }
}

// MARK: - Common Setting Items Builder
/// 常用设置项的便捷构建器
public struct JetSettingsItemBuilder {
    
    /// 恢复购买项
    public static func restorePurchase(
        icon: JetSettingIcon = .system("creditcard"),
        title: String = "Restore Purchase",
        action: @escaping () -> Void
    ) -> JetSettingItem {
        JetSettingItem(icon: icon, title: title, action: action)
    }
    
    /// 分享应用项
    public static func shareApp(
        icon: JetSettingIcon = .system("square.and.arrow.up"),
        title: String = "Share to Friends",
        action: @escaping () -> Void
    ) -> JetSettingItem {
        JetSettingItem(icon: icon, title: title, action: action)
    }
    
    /// 评价应用项
    public static func rateApp(
        icon: JetSettingIcon = .system("star.fill"),
        title: String = "Rate Us",
        action: @escaping () -> Void
    ) -> JetSettingItem {
        JetSettingItem(icon: icon, title: title, action: action)
    }
    
    /// 服务条款项
    public static func termsOfUse(
        icon: JetSettingIcon = .system("doc.text"),
        title: String = "Terms of Use",
        url: String = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
        action: @escaping () -> Void
    ) -> JetSettingItem {
        JetSettingItem(icon: icon, title: title, action: action)
    }
    
    /// 隐私政策项
    public static func privacyPolicy(
        icon: JetSettingIcon = .system("lock.shield"),
        title: String = "Privacy Policy",
        action: @escaping () -> Void
    ) -> JetSettingItem {
        JetSettingItem(icon: icon, title: title, action: action)
    }
    
    /// 反馈项
    public static func feedback(
        icon: JetSettingIcon = .system("envelope"),
        title: String = "Feedback",
        action: @escaping () -> Void
    ) -> JetSettingItem {
        JetSettingItem(icon: icon, title: title, action: action)
    }
    
    /// 帮助与支持项
    public static func helpAndSupport(
        icon: JetSettingIcon = .system("questionmark.app.fill"),
        title: String = "Help & Support",
        action: @escaping () -> Void
    ) -> JetSettingItem {
        JetSettingItem(icon: icon, title: title, action: action)
    }
    
    /// 新功能项
    public static func whatsNew(
        icon: JetSettingIcon = .system("sparkles"),
        title: String = "What's New",
        version: String? = nil,
        action: @escaping () -> Void
    ) -> JetSettingItem {
        JetSettingItem(icon: icon, title: title, detail: version, action: action)
    }
    
    /// 社交媒体项
    public static func socialMedia(
        platform: String,
        icon: JetSettingIcon,
        handle: String,
        action: @escaping () -> Void
    ) -> JetSettingItem {
        JetSettingItem(icon: icon, title: platform, detail: handle, action: action)
    }
}

// MARK: - Membership Card Presets
/// 会员卡片预设配置
public extension JetMembershipCardConfiguration {
    
    /// 渐变色会员卡片（AlarmApp 风格）
    static func gradientCard(
        title: String,
        subtitle: String,
        colors: [Color] = [
            Color(red: 0.83, green: 0.52, blue: 0.96),
            Color(red: 0.99, green: 0.55, blue: 0.37)
        ],
        onTap: @escaping () -> Void,
        isSubscribed: @escaping () -> Bool = { false }
    ) -> JetMembershipCardConfiguration {
        JetMembershipCardConfiguration(
            isEnabled: true,
            style: .gradient(colors: colors, startPoint: .top, endPoint: .bottom),
            title: title,
            subtitle: subtitle,
            onTap: onTap,
            isSubscribed: isSubscribed
        )
    }
    
    /// 图片背景会员卡片（WatermarkCamera 风格）
    static func imageCard(
        title: String,
        subtitle: String,
        imageName: String,
        buttonTitle: String = "Activate",
        activatedTitle: String = "Activated PRO",
        onTap: @escaping () -> Void,
        isSubscribed: @escaping () -> Bool = { false }
    ) -> JetMembershipCardConfiguration {
        JetMembershipCardConfiguration(
            isEnabled: true,
            style: .image(imageName),
            title: title,
            subtitle: subtitle,
            buttonTitle: buttonTitle,
            activatedTitle: activatedTitle,
            onTap: onTap,
            isSubscribed: isSubscribed
        )
    }
    
    /// 简约订阅行（DocumentScan 风格）
    static func subscriptionRow(
        title: String = "Subscription Membership",
        onTap: @escaping () -> Void
    ) -> JetMembershipCardConfiguration {
        JetMembershipCardConfiguration(
            isEnabled: true,
            style: .solid(Color(.secondarySystemBackground)),
            title: title,
            subtitle: "",
            onTap: onTap
        )
    }
}
