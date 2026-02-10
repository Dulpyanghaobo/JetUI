//
//  JetAppConfig.swift
//  JetUI
//
//  Created by i564407 on 2/9/26.
//

import SwiftUI

// MARK: - App Configuration
/// 应用配置，用于简化 SettingsView 的使用
/// 用户只需提供必要的 URL 和文本，其他都由 JetUI 内部处理
public struct JetAppConfig {
    
    // MARK: - App Identity
    /// App 名称
    public let appName: String
    /// App Store URL
    public let appStoreURL: String
    /// 分享文案
    public let shareText: String
    
    // MARK: - Legal URLs
    /// 服务条款 URL
    public let termsOfUseURL: String
    /// 隐私政策 URL
    public let privacyPolicyURL: String
    
    // MARK: - Contact
    /// 反馈邮箱
    public let feedbackEmail: String
    /// 邮件主题
    public let feedbackSubject: String
    
    // MARK: - Style
    /// 设置页面风格
    public let style: JetSettingsStyle
    
    // MARK: - Subscription (Optional)
    /// 订阅配置（可选）
    public let subscriptionConfig: JetSubscriptionConfig?
    
    public init(
        appName: String,
        appStoreURL: String,
        shareText: String,
        termsOfUseURL: String = JetSettingsURLs.appleTermsOfUse,
        privacyPolicyURL: String,
        feedbackEmail: String,
        feedbackSubject: String? = nil,
        style: JetSettingsStyle = .dark,
        subscriptionConfig: JetSubscriptionConfig? = nil
    ) {
        self.appName = appName
        self.appStoreURL = appStoreURL
        self.shareText = shareText
        self.termsOfUseURL = termsOfUseURL
        self.privacyPolicyURL = privacyPolicyURL
        self.feedbackEmail = feedbackEmail
        self.feedbackSubject = feedbackSubject ?? "\(appName) Feedback"
        self.style = style
        self.subscriptionConfig = subscriptionConfig
    }
}

// MARK: - Settings Style
/// 设置页面风格枚举
public enum JetSettingsStyle {
    /// 深色主题（TimeProof/WatermarkCamera）
    case dark
    /// 深色主题 + 会员卡（WatermarkCamera）
    case darkWithMembership
    /// 浅色卡片主题（AlarmApp）
    case lightCard
    /// 标准系统主题（DocumentScan）
    case standard
}

// MARK: - Settings Subscription UI Config
/// 设置页面的会员卡 UI 配置（与 JetSubscriptionConfig 分离，避免名称冲突）
public struct JetSettingsSubscriptionUIConfig {
    /// 会员卡背景图片名称（可选）
    public let membershipCardImage: String?
    /// 会员卡标题
    public let membershipTitle: String
    /// 会员卡副标题
    public let membershipSubtitle: String
    
    public init(
        membershipCardImage: String? = nil,
        membershipTitle: String = "Pro",
        membershipSubtitle: String = "Unlock all premium features"
    ) {
        self.membershipCardImage = membershipCardImage
        self.membershipTitle = membershipTitle
        self.membershipSubtitle = membershipSubtitle
    }
}

// MARK: - Built-in Strings
/// 内置的本地化文字
public struct JetStrings {
    public static let shared = JetStrings()
    
    private init() {}
    
    // Settings
    public func settings() -> String { "Settings" }
    public func restorePurchase() -> String { "Restore Purchase" }
    public func shareToFriends() -> String { "Share to Friends" }
    public func rateUs() -> String { "Rate Us" }
    public func termsOfUse() -> String { "Terms of Use" }
    public func privacyPolicy() -> String { "Privacy Policy" }
    public func feedback() -> String { "Feedback" }
    
    // Alerts
    public func restoreFailed() -> String { "Restore Failed" }
    public func restoreSuccessful() -> String { "Restore Successful" }
    public func purchasesRestored() -> String { "Your purchases have been restored." }
    public func ok() -> String { "OK" }
    public func cancel() -> String { "Cancel" }
    public func done() -> String { "Done" }
    
    // Membership
    public func activate() -> String { "Activate" }
    public func activated() -> String { "Activated" }
    public func pro() -> String { "PRO" }
    public func unlockAllFeatures() -> String { "Unlock all premium features" }
}
