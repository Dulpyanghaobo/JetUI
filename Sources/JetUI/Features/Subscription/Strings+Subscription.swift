//
//  Strings+Subscription.swift
//  JetUI
//
//  订阅模块本地化字符串扩展
//  使用方式: SubL.title.unlockPro 或 SubL.button.continue
//

import Foundation

// MARK: - Subscription Localization Helper

/// 订阅模块本地化字符串命名空间
public enum SubL {
    
    // MARK: - Private Helpers
    
    /// 获取 JetUI 模块的 Bundle
    /// 在 Swift Package 中使用 Bundle.module 访问资源
    private static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        // 非 SPM 环境下的回退方案
        return Bundle(for: BundleToken.self)
        #endif
    }
    
    /// 从 Subscription.strings 获取本地化字符串
    private static func localized(_ key: String) -> String {
        return NSLocalizedString(key, tableName: "Subscription", bundle: bundle, comment: "")
    }
    
    private static func localizedFormat(_ key: String, _ args: CVarArg...) -> String {
        let format = localized(key)
        return String(format: format, arguments: args)
    }
    
    // MARK: - Title
    
    /// Paywall 标题文案
    public enum Title {
        /// "Unlock Pro" / "解锁专业版"
        public static var unlockPro: String {
            localized("subscription.title.unlock_pro")
        }
        
        /// "Start Your Free Trial" / "开始免费试用"
        public static var startTrial: String {
            localized("subscription.title.start_trial")
        }
        
        /// "How Free Trial Works" / "免费试用如何运作"
        public static var howTrialWorks: String {
            localized("subscription.title.how_trial_works")
        }
        
        /// "Unlock Unlimited Access" / "解锁无限访问"
        public static var unlimitedAccess: String {
            localized("subscription.title.unlimited_access")
        }
    }
    
    // MARK: - Period
    
    /// 订阅周期文案
    public enum Period {
        /// "Yearly" / "年度"
        public static var yearly: String {
            localized("subscription.period.yearly")
        }
        
        /// "Monthly" / "月度"
        public static var monthly: String {
            localized("subscription.period.monthly")
        }
        
        /// "Weekly" / "每周"
        public static var weekly: String {
            localized("subscription.period.weekly")
        }
        
        /// "Daily" / "每日"
        public static var daily: String {
            localized("subscription.period.daily")
        }
        
        /// "Lifetime" / "终身"
        public static var lifetime: String {
            localized("subscription.period.lifetime")
        }
        
        /// "%d Months" / "%d 个月"
        public static func months(_ count: Int) -> String {
            localizedFormat("subscription.period.months_format", count)
        }
        
        /// "%d Weeks" / "%d 周"
        public static func weeks(_ count: Int) -> String {
            localizedFormat("subscription.period.weeks_format", count)
        }
        
        /// "%d Days" / "%d 天"
        public static func days(_ count: Int) -> String {
            localizedFormat("subscription.period.days_format", count)
        }
        
        /// "%d Years" / "%d 年"
        public static func years(_ count: Int) -> String {
            localizedFormat("subscription.period.years_format", count)
        }
    }
    
    // MARK: - Trial
    
    /// 试用相关文案
    public enum Trial {
        /// "Free Trial" / "免费试用"
        public static var freeTrial: String {
            localized("subscription.trial.free_trial")
        }
        
        /// "%d Day Free Trial" / "%d 天免费试用"
        public static func dayFreeTrial(_ days: Int) -> String {
            localizedFormat("subscription.trial.day_free_trial", days)
        }
        
        /// "%d Week Free Trial" / "%d 周免费试用"
        public static func weekFreeTrial(_ weeks: Int) -> String {
            localizedFormat("subscription.trial.week_free_trial", weeks)
        }
        
        /// "%d Month Free Trial" / "%d 个月免费试用"
        public static func monthFreeTrial(_ months: Int) -> String {
            localizedFormat("subscription.trial.month_free_trial", months)
        }
        
        /// "%d days free" / "%d 天免费"
        public static func daysFree(_ days: Int) -> String {
            localizedFormat("subscription.trial.days_free", days)
        }
        
        /// "%@ free, then %@" / "%@ 免费，之后 %@"
        public static func freeThenPrice(trialPeriod: String, price: String) -> String {
            localizedFormat("subscription.trial.free_then_price", trialPeriod, price)
        }
        
        /// "%@ free, then %@" / "%@ 免费，之后 %@" (别名方法)
        public static func freeThenPrice(_ trialPeriod: String, _ price: String) -> String {
            freeThenPrice(trialPeriod: trialPeriod, price: price)
        }
        
        /// "%@ free trial" / "%@ 免费试用"
        public static func freeTrial(_ period: String) -> String {
            localizedFormat("subscription.trial.free_trial_period", period)
        }
        
        /// "Today - Full Access" / "今天 - 完整访问"
        public static var todayFullAccess: String {
            localized("subscription.trial.today_full_access")
        }
        
        /// "Day 5 - Trial Reminder" / "第 5 天 - 试用提醒"
        public static var day5Reminder: String {
            localized("subscription.trial.day5_reminder")
        }
        
        /// "Day 7 - Trial Ends" / "第 7 天 - 试用结束"
        public static var day7Ends: String {
            localized("subscription.trial.day7_ends")
        }
        
        /// "Start capture with Pro features" / "开始使用专业版功能拍摄"
        public static var startsFeatures: String {
            localized("subscription.trial.starts_features")
        }
        
        /// "We'll remind you before trial ends" / "我们会在试用结束前提醒您"
        public static var remindBeforeEnds: String {
            localized("subscription.trial.remind_before_ends")
        }
        
        /// "Subscription starts" / "订阅开始"
        public static var subscriptionStarts: String {
            localized("subscription.trial.subscription_starts")
        }
    }
    
    // MARK: - Button
    
    /// 按钮文案
    public enum Button {
        /// "Continue" / "继续"
        public static var `continue`: String {
            localized("subscription.button.continue")
        }
        
        /// "Restore" / "恢复"
        public static var restore: String {
            localized("subscription.button.restore")
        }
        
        /// "Restore Purchases" / "恢复购买"
        public static var restorePurchases: String {
            localized("subscription.button.restore_purchases")
        }
        
        /// "Processing..." / "处理中..."
        public static var processing: String {
            localized("subscription.button.processing")
        }
        
        /// "Retry" / "重试"
        public static var retry: String {
            localized("subscription.button.retry")
        }
        
        /// "Loading..." / "加载中..."
        public static var loading: String {
            localized("subscription.button.loading")
        }
    }
    
    // MARK: - Price
    
    /// 价格显示文案
    public enum Price {
        /// "%@/year" / "%@/年"
        public static func perYear(_ price: String) -> String {
            localizedFormat("subscription.price.per_year", price)
        }
        
        /// "%@/month" / "%@/月"
        public static func perMonth(_ price: String) -> String {
            localizedFormat("subscription.price.per_month", price)
        }
        
        /// "%@/week" / "%@/周"
        public static func perWeek(_ price: String) -> String {
            localizedFormat("subscription.price.per_week", price)
        }
        
        /// "%@/day" / "%@/天"
        public static func perDay(_ price: String) -> String {
            localizedFormat("subscription.price.per_day", price)
        }
        
        /// "Save %d%%" / "节省 %d%%"
        public static func savePercent(_ percent: Int) -> String {
            localizedFormat("subscription.price.save_percent", percent)
        }
        
        /// "Best Value" / "最佳优惠"
        public static var bestValue: String {
            localized("subscription.price.best_value")
        }
        
        /// "Most Popular" / "最受欢迎"
        public static var mostPopular: String {
            localized("subscription.price.most_popular")
        }
    }
    
    // MARK: - Legal
    
    /// 法律条款文案
    public enum Legal {
        /// "Privacy Policy" / "隐私政策"
        public static var privacyPolicy: String {
            localized("subscription.legal.privacy_policy")
        }
        
        /// "Terms of Service" / "服务条款"
        public static var termsOfService: String {
            localized("subscription.legal.terms_of_service")
        }
        
        /// "Terms & Conditions" / "条款与条件"
        public static var termsConditions: String {
            localized("subscription.legal.terms_conditions")
        }
        
        /// "Auto-renewable. Cancel anytime." / "自动续订，可随时取消。"
        public static var autoRenewalTip: String {
            localized("subscription.legal.auto_renewal_tip")
        }
        
        /// "One-time purchase, valid for life." / "一次性购买，终身有效。"
        public static var lifetimeTip: String {
            localized("subscription.legal.lifetime_tip")
        }
    }
    
    // MARK: - Error
    
    /// 错误信息
    public enum Error {
        /// "Failed to load products" / "加载产品失败"
        public static var loadFailed: String {
            localized("subscription.error.load_failed")
        }
        
        /// "Purchase failed" / "购买失败"
        public static var purchaseFailed: String {
            localized("subscription.error.purchase_failed")
        }
        
        /// "Purchase was cancelled" / "购买已取消"
        public static var purchaseCancelled: String {
            localized("subscription.error.purchase_cancelled")
        }
        
        /// "Purchase is pending" / "购买等待中"
        public static var purchasePending: String {
            localized("subscription.error.purchase_pending")
        }
        
        /// "An unknown error occurred" / "发生未知错误"
        public static var unknown: String {
            localized("subscription.error.unknown")
        }
        
        /// "No products available" / "暂无可用产品"
        public static var noProducts: String {
            localized("subscription.error.no_products")
        }
        
        /// "No active subscription found" / "未找到有效订阅"
        public static var noSubscriptionFound: String {
            localized("subscription.error.no_subscription_found")
        }
        
        /// "No active subscription found" / "未找到有效订阅" (别名)
        public static var noActiveSubscription: String {
            noSubscriptionFound
        }
        
        /// "Failed to restore purchases" / "恢复购买失败"
        public static var restoreFailed: String {
            localized("subscription.error.restore_failed")
        }
    }
    
    // MARK: - Benefit
    
    /// 权益/功能点文案
    public enum Benefit {
        /// "Unlimited Access" / "无限访问"
        public static var unlimitedAccess: String {
            localized("subscription.benefit.unlimited_access")
        }
        
        /// "No Ads" / "无广告"
        public static var noAds: String {
            localized("subscription.benefit.no_ads")
        }
        
        /// "Premium Features" / "高级功能"
        public static var premiumFeatures: String {
            localized("subscription.benefit.premium_features")
        }
        
        /// "Priority Support" / "优先支持"
        public static var prioritySupport: String {
            localized("subscription.benefit.priority_support")
        }
        
        /// "Cloud Sync" / "云同步"
        public static var cloudSync: String {
            localized("subscription.benefit.cloud_sync")
        }
        
        /// "Unlimited Templates" / "无限模板"
        public static var unlimitedTemplates: String {
            localized("subscription.benefit.unlimited_templates")
        }
        
        /// "Unlimited Timestamps" / "无限时间戳"
        public static var unlimitedTimestamps: String {
            localized("subscription.benefit.unlimited_timestamps")
        }
        
        /// "Professional Filters" / "专业滤镜"
        public static var proFilters: String {
            localized("subscription.benefit.pro_filters")
        }
        
        /// "4K Export" / "4K 导出"
        public static var export4K: String {
            localized("subscription.benefit.4k_export")
        }
        
        /// "Watermark Free" / "无水印"
        public static var watermarkFree: String {
            localized("subscription.benefit.watermark_free")
        }
        
        /// "All Premium Features" / "所有高级功能"
        public static var allPremium: String {
            localized("subscription.benefit.all_premium")
        }
    }
    
    // MARK: - Status
    
    /// 订阅状态文案
    public enum Status {
        /// "Active" / "已激活"
        public static var active: String {
            localized("subscription.status.active")
        }
        
        /// "Expired" / "已过期"
        public static var expired: String {
            localized("subscription.status.expired")
        }
        
        /// "Trial Active" / "试用中"
        public static var trialActive: String {
            localized("subscription.status.trial_active")
        }
        
        /// "Expires on %@" / "到期时间：%@"
        public static func expiresOn(_ date: String) -> String {
            localizedFormat("subscription.status.expires_on", date)
        }
        
        /// "Renews on %@" / "续订时间：%@"
        public static func renewsOn(_ date: String) -> String {
            localizedFormat("subscription.status.renews_on", date)
        }
    }
    
    // MARK: - Accessibility
    
    /// 无障碍访问文案
    public enum Accessibility {
        /// "Close paywall" / "关闭付费墙"
        public static var closeButton: String {
            localized("subscription.accessibility.close_button")
        }
        
        /// "Restore previous purchases" / "恢复之前的购买"
        public static var restoreButton: String {
            localized("subscription.accessibility.restore_button")
        }
        
        /// "%@ plan selected" / "已选择 %@ 方案"
        public static func planSelected(_ planName: String) -> String {
            localizedFormat("subscription.accessibility.plan_selected", planName)
        }
        
        /// "%@, %@" / "%@，%@"
        public static func priceOption(name: String, price: String) -> String {
            localizedFormat("subscription.accessibility.price_option", name, price)
        }
    }
}

// MARK: - Convenience Type Alias

/// 订阅模块本地化字符串的短别名
public typealias SubscriptionStrings = SubL

// MARK: - Bundle Token (非 SPM 环境)

#if !SWIFT_PACKAGE
/// 用于在非 SPM 环境中定位 Bundle 的辅助类
private final class BundleToken {}
#endif
