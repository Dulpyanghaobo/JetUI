//
//  AnalyticsManager.swift
//  JetUI
//
//  分析管理器 - 提供统一的事件追踪接口
//  支持 Firebase Analytics 或其他分析后端
//

import Foundation

// MARK: - Analytics Provider Protocol

/// 分析后端协议 - 由宿主 App 实现具体的分析 SDK 调用
public protocol AnalyticsProvider {
    /// 记录事件
    func logEvent(_ name: String, parameters: [String: Any]?)
    /// 设置用户属性
    func setUserProperty(_ value: String?, forName name: String)
    /// 记录屏幕浏览
    func logScreen(_ screenName: String, screenClass: String)
}

// MARK: - Analytics Context

/// 分析上下文 - 包含通用参数
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

// MARK: - Analytics Manager

/// 分析管理器
public enum AnalyticsManager {
    
    // MARK: - Configuration
    
    /// 分析提供者（由宿主 App 注入）
    public static var provider: AnalyticsProvider?
    
    /// 上下文
    private static var ctx = AnalyticsContext()
    
    /// 更新上下文
    public static func updateContext(_ modifier: (inout AnalyticsContext) -> Void) {
        modifier(&ctx)
    }
    
    /// 获取当前上下文（只读）
    public static var context: AnalyticsContext { ctx }
    
    // MARK: - Base Methods
    
    /// 记录事件
    public static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        provider?.logEvent(name, parameters: ctx.merged(parameters))
    }
    
    /// 采样记录事件
    public static func logSampled(_ name: String, rate: Double, parameters: [String: Any]? = nil) {
        guard rate > 0, Double.random(in: 0...1) < rate else { return }
        logEvent(name, parameters: parameters)
    }
    
    /// 记录屏幕浏览
    public static func logScreen(_ screen: String) {
        provider?.logScreen(screen, screenClass: "SwiftUI")
    }
    
    /// 设置用户属性
    public static func setUserProperty(_ value: String?, forName name: String) {
        provider?.setUserProperty(value, forName: name)
    }
    
    // MARK: - Helper Methods
    
    /// 记录按钮点击
    public static func logButtonClick(_ buttonName: String) {
        logEvent("button_click", parameters: ["name": buttonName])
    }
    
    /// 记录订阅
    public static func logSubscription(plan: String) {
        logEvent("subscription", parameters: ["plan": plan])
    }
    
    // MARK: - Photo & Video Events
    
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
        logEvent("paywall_show", parameters: ["source": source])
    }
    
    public static func logPurchaseStart(productId: String, planType: String) {
        logEvent("purchase_start", parameters: [
            "product_id": productId,
            "plan_type": planType
        ])
    }
    
    public static func logPurchaseSuccess(productId: String, planType: String, price: String) {
        logEvent("purchase_success", parameters: [
            "product_id": productId,
            "plan_type": planType,
            "price": price
        ])
    }
    
    public static func logPurchaseFailure(productId: String, error: String) {
        logEvent("purchase_failure", parameters: [
            "product_id": productId,
            "error": error
        ])
    }
    
    public static func logRestorePurchase(success: Bool) {
        logEvent("restore_purchase", parameters: ["success": success])
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
}
