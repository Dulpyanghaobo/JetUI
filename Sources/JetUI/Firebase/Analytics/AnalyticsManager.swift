//
//  AnalyticsManager.swift
//  JetUI
//
//  分析管理器 - 直接集成 Firebase Analytics
//

import Foundation
import FirebaseAnalytics

// MARK: - Paywall Event Names

/// Paywall 事件名称常量
public enum JetPaywallEvent {
    public static let view = "paywall_view"
    public static let action = "paywall_action"
    public static let optionSelect = "paywall_option_select"
    public static let purchaseStart = "paywall_purchase_start"
    public static let purchaseSuccess = "paywall_purchase_success"
    public static let purchaseCancelled = "paywall_purchase_cancelled"
    public static let purchaseFailed = "paywall_purchase_failed"
    public static let restoreStart = "paywall_restore_start"
    public static let restoreSuccess = "paywall_restore_success"
    public static let restoreFailed = "paywall_restore_failed"
    public static let restoreNoSubscription = "paywall_restore_no_subscription"
}

public typealias JetAnalyticsManager = AnalyticsManager

public struct AnalyticsContext {
    public var sessionId: String = UUID().uuidString
    public var pro: Bool = false
    public var lens: String = "back"
    public var aspectRatio: String = "3_4"
    public var templateCat: String?
    public var appVersion: String = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0"
    public var locale: String = Locale.current.identifier
    
    public init() {}
    
    public func merged(_ extra: [String: Any]?) -> [String: Any] {
        var p: [String: Any] = [
            "session_id": sessionId,
            "pro": pro,
            "lens": lens,
            "ar": aspectRatio,
            "app_ver": appVersion,
            "locale": locale
        ]
        if let t = templateCat { p["template_cat"] = t }
        extra?.forEach { p[$0.key] = $0.value }
        return p
    }
}

public enum AnalyticsManager {
    
    // MARK: - Configuration
    private static var ctx = AnalyticsContext()
    
    /// 是否启用分析（默认启用）
    public static var isEnabled: Bool = true
    
    /// 更新上下文
    public static func updateContext(_ modifier: (inout AnalyticsContext) -> Void) {
        modifier(&ctx)
    }
    
    /// 获取当前上下文（只读）
    public static var context: AnalyticsContext { ctx }
    
    // MARK: - Base Methods
    
    /// 记录事件
    public static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        guard isEnabled else { return }
        Analytics.logEvent(name, parameters: ctx.merged(parameters))
    }
    
    /// 采样记录事件
    public static func logSampled(_ name: String, rate: Double, parameters: [String: Any]? = nil) {
        guard rate > 0, Double.random(in: 0...1) < rate else { return }
        logEvent(name, parameters: parameters)
    }
    
    /// 记录屏幕浏览
    public static func logScreen(_ screen: String) {
        guard isEnabled else { return }
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screen,
            AnalyticsParameterScreenClass: "SwiftUI"
        ])
    }
    
    /// 设置用户属性
    public static func setUserProperty(_ value: String?, forName name: String) {
        guard isEnabled else { return }
        Analytics.setUserProperty(value, forName: name)
    }
    
    /// 设置用户 ID
    public static func setUserID(_ userID: String?) {
        guard isEnabled else { return }
        Analytics.setUserID(userID)
    }
    
    /// 设置分析收集状态
    public static func setAnalyticsCollectionEnabled(_ enabled: Bool) {
        Analytics.setAnalyticsCollectionEnabled(enabled)
        isEnabled = enabled
    }
    
    public static func logButtonClick(_ buttonName: String) {
        logEvent("button_click", parameters: ["name": buttonName])
    }
    
    /// 记录订阅
    public static func logSubscription(plan: String) {
        logEvent("subscription", parameters: ["plan": plan])
    }
    
    public static func logPhotoCapture(template: String?, hasWatermark: Bool, aspectRatio: String) {
        logEvent("photo_capture", parameters: [
            "template": template ?? "none",
            "has_watermark": hasWatermark,
            "aspect_ratio": aspectRatio
        ])
    }
    
    public static func logPhotoSaveSuccess(localId: String, fileSize: Int64) {
        logEvent("photo_save_success", parameters: [
            "local_id": localId,
            "file_size_kb": Int(fileSize / 1024)
        ])
    }
    
    public static func logPhotoSaveFailure(error: String) {
        logEvent("photo_save_failure", parameters: ["error": error])
    }
    
    // MARK: - Template Events
    public static func logTemplateSelect(templateId: String, templateName: String, category: String, source: String) {
        logEvent("template_select", parameters: [
            "template_id": templateId,
            "template_name": templateName,
            "category": category,
            "source": source
        ])
    }
    
    public static func logTemplateDownload(templateId: String, success: Bool, source: String) {
        logEvent("template_download", parameters: [
            "template_id": templateId,
            "success": success,
            "source": source
        ])
    }
    
    public static func logTemplateEdit(templateId: String, action: String) {
        logEvent("template_edit", parameters: [
            "template_id": templateId,
            "action": action
        ])
    }
    
    // MARK: - Subscription Events
    
    public static func logPaywallShow(source: String) {
        logEvent(JetPaywallEvent.view, parameters: ["source": source])
    }
    
    /// 记录 Paywall 显示（带变体）
    public static func logPaywallView(variant: String) {
        logEvent(JetPaywallEvent.view, parameters: ["variant": variant])
    }
    
    public static func logPurchaseStart(productId: String, planType: String) {
        logEvent(JetPaywallEvent.purchaseStart, parameters: [
            "product_id": productId,
            "plan_type": planType
        ])
    }
    
    /// 记录购买开始（简化版，仅 productId）
    public static func logPurchaseStart(productId: String) {
        logEvent(JetPaywallEvent.purchaseStart, parameters: [
            "product_id": productId
        ])
    }
    
    public static func logPurchaseSuccess(productId: String, planType: String, price: String) {
        logEvent(JetPaywallEvent.purchaseSuccess, parameters: [
            "product_id": productId,
            "plan_type": planType,
            "price": price
        ])
    }
    
    /// 记录购买成功（简化版，仅 productId）
    public static func logPurchaseSuccess(productId: String) {
        logEvent(JetPaywallEvent.purchaseSuccess, parameters: [
            "product_id": productId
        ])
    }
    
    /// 记录购买取消
    public static func logPurchaseCancelled(productId: String) {
        logEvent(JetPaywallEvent.purchaseCancelled, parameters: [
            "product_id": productId
        ])
    }
    
    public static func logPurchaseFailure(productId: String, error: String) {
        logEvent(JetPaywallEvent.purchaseFailed, parameters: [
            "product_id": productId,
            "error": error
        ])
    }
    
    /// 记录购买失败（别名）
    public static func logPurchaseFailed(productId: String, error: String) {
        logPurchaseFailure(productId: productId, error: error)
    }
    
    public static func logRestorePurchase(success: Bool) {
        logEvent("restore_purchase", parameters: ["success": success])
    }
    
    /// 记录恢复购买成功
    public static func logRestoreSuccess() {
        logEvent(JetPaywallEvent.restoreSuccess)
    }
    
    /// 记录恢复购买失败
    public static func logRestoreFailed(error: String) {
        logEvent(JetPaywallEvent.restoreFailed, parameters: ["error": error])
    }
    
    // MARK: - User Journey Events
    
    public static func logOnboardingStep(step: Int, action: String) {
        logEvent("onboarding_step", parameters: [
            "step": step,
            "action": action
        ])
    }
    
    public static func logFeatureDiscovery(featureName: String) {
        logEvent("feature_discovery", parameters: ["feature": featureName])
    }
    
    // MARK: - AI Events
    
    public static func logAIGenerateStart(prompt: String) {
        logEvent("ai_generate_start", parameters: ["prompt": prompt])
    }
    
    public static func logAIGenerateSuccess(prompt: String, duration: Double) {
        logEvent("ai_generate_success", parameters: [
            "prompt": prompt,
            "duration_s": duration
        ])
    }
    
    public static func logAIGenerateFailure(prompt: String, error: String) {
        logEvent("ai_generate_failure", parameters: [
            "prompt": prompt,
            "error": error
        ])
    }
    
    // MARK: - Share Events
    
    public static func logPhotoShare(method: String, assetCount: Int) {
        logEvent("photo_share", parameters: [
            "method": method,
            "asset_count": assetCount
        ])
    }
    
    // MARK: - Error Events
    
    public static func logError(category: String, message: String, fatal: Bool = false) {
        logEvent("app_error", parameters: [
            "category": category,
            "message": message,
            "fatal": fatal
        ])
    }
    
    // MARK: - Firebase Standard Events
    
    /// 记录登录事件
    public static func logLogin(method: String) {
        logEvent(AnalyticsEventLogin, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    /// 记录注册事件
    public static func logSignUp(method: String) {
        logEvent(AnalyticsEventSignUp, parameters: [
            AnalyticsParameterMethod: method
        ])
    }
    
    /// 记录搜索事件
    public static func logSearch(searchTerm: String) {
        logEvent(AnalyticsEventSearch, parameters: [
            AnalyticsParameterSearchTerm: searchTerm
        ])
    }
    
    /// 记录分享事件
    public static func logShare(contentType: String, itemId: String, method: String) {
        logEvent(AnalyticsEventShare, parameters: [
            AnalyticsParameterContentType: contentType,
            AnalyticsParameterItemID: itemId,
            AnalyticsParameterMethod: method
        ])
    }
    
    /// 记录选择内容事件
    public static func logSelectContent(contentType: String, itemId: String) {
        logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterContentType: contentType,
            AnalyticsParameterItemID: itemId
        ])
    }
    
    /// 记录教程开始
    public static func logTutorialBegin() {
        logEvent(AnalyticsEventTutorialBegin)
    }
    
    /// 记录教程完成
    public static func logTutorialComplete() {
        logEvent(AnalyticsEventTutorialComplete)
    }
    
    /// 记录应用打开
    public static func logAppOpen() {
        logEvent(AnalyticsEventAppOpen)
    }
    
    // MARK: - App Specific Events
    
    /// 记录水印应用事件
    public static func logWatermarkApplied(templateId: String?, isCustom: Bool) {
        logEvent("watermark_applied", parameters: [
            "template_id": templateId ?? "none",
            "is_custom": isCustom
        ])
    }
    
    /// 记录滤镜应用事件
    public static func logFilterApplied(filterName: String) {
        logEvent("filter_applied", parameters: [
            "filter_name": filterName
        ])
    }
    
    /// 记录相册访问事件
    public static func logGalleryAccess(source: String) {
        logEvent("gallery_access", parameters: [
            "source": source
        ])
    }
    
    /// 记录视频录制事件
    public static func logVideoRecording(duration: Double, hasWatermark: Bool) {
        logEvent("video_recording", parameters: [
            "duration_s": duration,
            "has_watermark": hasWatermark
        ])
    }
    
    /// 记录模板收藏事件
    public static func logTemplateFavorite(templateId: String, action: String) {
        logEvent("template_favorite", parameters: [
            "template_id": templateId,
            "action": action // "add" or "remove"
        ])
    }
    
    /// 记录签到事件
    public static func logDailySignIn(day: Int, streak: Int) {
        logEvent("daily_sign_in", parameters: [
            "day": day,
            "streak": streak
        ])
    }
    
    /// 记录任务完成事件
    public static func logTaskComplete(taskId: String, taskType: String, reward: Int) {
        logEvent("task_complete", parameters: [
            "task_id": taskId,
            "task_type": taskType,
            "reward": reward
        ])
    }
    
    /// 记录等级提升事件
    public static func logLevelUp(newLevel: Int, totalXP: Int) {
        logEvent("level_up", parameters: [
            "new_level": newLevel,
            "total_xp": totalXP
        ])
    }
    
    /// 记录成就解锁事件
    public static func logAchievementUnlock(achievementId: String, achievementName: String) {
        logEvent("achievement_unlock", parameters: [
            "achievement_id": achievementId,
            "achievement_name": achievementName
        ])
    }
}
