//
//  JetPaywallTypes.swift
//  JetUI
//
//  Paywall 类型定义 - UI 风格与内容配置分离
//

import SwiftUI

// MARK: - Paywall Style

/// Paywall UI 风格枚举
public enum JetPaywallStyle {
    /// 列表风格 - 对应 JetPaywallView
    case list
    
    /// 时间轴风格 - 对应 JetTrialPaywallView
    case timeline
}

// MARK: - Paywall Content

/// Paywall 统一内容容器
public struct JetPaywallContent {
    
    // MARK: - Sub Types
    
    /// 时间轴步骤（Timeline 风格专用）
    public struct TimelineStep {
        /// 图标名称（SF Symbol）
        public let icon: String
        
        /// 标题
        public let title: String
        
        /// 副标题/描述
        public let subtitle: String
        
        public init(icon: String, title: String, subtitle: String) {
            self.icon = icon
            self.title = title
            self.subtitle = subtitle
        }
    }
    
    /// 权益项（Timeline 风格专用）
    public struct BenefitItem {
        /// 图标名称（SF Symbol）
        public let icon: String
        
        /// 标题
        public let title: String
        
        public init(icon: String, title: String) {
            self.icon = icon
            self.title = title
        }
    }
    
    // MARK: - Basic Appearance
    
    /// 品牌标题
    public var brandTitle: String
    
    /// 强调色
    public var accentColor: Color
    
    /// 背景色
    public var backgroundColor: Color
    
    /// 背景图片名称（可选）
    public var backgroundImageName: String?
    
    // MARK: - Common Texts
    
    /// 继续按钮文案
    public var continueText: String
    
    /// 恢复购买文案
    public var restoreText: String
    
    /// 处理中文案
    public var processingText: String
    
    /// 重试文案
    public var retryText: String
    
    /// 加载失败文案
    public var loadFailedText: String
    
    // MARK: - Legal Links
    
    /// 隐私政策 URL
    public var privacyPolicyURL: URL?
    
    /// 服务条款 URL
    public var termsURL: URL?
    
    /// 隐私政策文案
    public var privacyText: String
    
    /// 服务条款文案
    public var termsText: String
    
    // MARK: - List Style Data
    
    /// 权益列表（List 风格专用）
    public var benefits: [String]
    
    /// 高亮关键词（List 风格专用）
    public var highlightKeyword: String?
    
    // MARK: - Timeline Style Data
    
    /// 时间轴步骤（Timeline 风格专用）
    public var timelineSteps: [TimelineStep]
    
    /// 复杂权益项（Timeline 风格专用）
    public var complexBenefits: [BenefitItem]
    
    // MARK: - Initialization
    
    public init(
        // Basic Appearance
        brandTitle: String = "Unlock Pro",
        accentColor: Color = .blue,
        backgroundColor: Color = .black,
        backgroundImageName: String? = nil,
        
        // Common Texts
        continueText: String = "Continue",
        restoreText: String = "Restore Purchases",
        processingText: String = "Processing...",
        retryText: String = "Retry",
        loadFailedText: String = "Failed to load products",
        
        // Legal Links
        privacyPolicyURL: URL? = nil,
        termsURL: URL? = nil,
        privacyText: String = "Privacy Policy",
        termsText: String = "Terms of Service",
        
        // List Style Data
        benefits: [String] = [],
        highlightKeyword: String? = nil,
        
        // Timeline Style Data
        timelineSteps: [TimelineStep] = [],
        complexBenefits: [BenefitItem] = []
    ) {
        self.brandTitle = brandTitle
        self.accentColor = accentColor
        self.backgroundColor = backgroundColor
        self.backgroundImageName = backgroundImageName
        
        self.continueText = continueText
        self.restoreText = restoreText
        self.processingText = processingText
        self.retryText = retryText
        self.loadFailedText = loadFailedText
        
        self.privacyPolicyURL = privacyPolicyURL
        self.termsURL = termsURL
        self.privacyText = privacyText
        self.termsText = termsText
        
        self.benefits = benefits
        self.highlightKeyword = highlightKeyword
        
        self.timelineSteps = timelineSteps
        self.complexBenefits = complexBenefits
    }
}

// MARK: - Presets

extension JetPaywallContent {
    
    /// 默认的 List 风格内容
    public static var defaultList: JetPaywallContent {
        JetPaywallContent(
            brandTitle: "Unlock Pro",
            accentColor: .blue,
            backgroundColor: .black,
            benefits: [
                "Unlimited Access",
                "No Ads",
                "Premium Features",
                "Priority Support"
            ]
        )
    }
    
    /// 默认的 Timeline 风格内容
    public static var defaultTimeline: JetPaywallContent {
        JetPaywallContent(
            brandTitle: "Start Your Free Trial",
            accentColor: .yellow,
            backgroundColor: .black,
            timelineSteps: [
                TimelineStep(
                    icon: "lock.open.fill",
                    title: "Today",
                    subtitle: "Instant access to all features"
                ),
                TimelineStep(
                    icon: "bell.fill",
                    title: "Day 5",
                    subtitle: "Reminder before trial ends"
                ),
                TimelineStep(
                    icon: "star.fill",
                    title: "Day 7",
                    subtitle: "Trial converts to subscription"
                )
            ],
            complexBenefits: [
                BenefitItem(icon: "infinity", title: "Unlimited Access"),
                BenefitItem(icon: "cloud.fill", title: "Cloud Sync"),
                BenefitItem(icon: "sparkles", title: "Premium Features"),
                BenefitItem(icon: "xmark.circle.fill", title: "No Ads")
            ]
        )
    }
}

// MARK: - Convenience Extensions

extension JetPaywallContent.TimelineStep: Identifiable {
    public var id: String { "\(icon)_\(title)" }
}

extension JetPaywallContent.BenefitItem: Identifiable {
    public var id: String { "\(icon)_\(title)" }
}
