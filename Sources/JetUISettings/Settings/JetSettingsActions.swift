//
//  JetSettingsActions.swift
//  JetUI
//
//  Created by i564407 on 2/9/26.
//

import SwiftUI
import StoreKit

// MARK: - Settings Actions
/// 设置页面常用操作的工具类
public struct JetSettingsActions {
    
    // MARK: - Open URL
    /// 打开 URL
    public static func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        #if canImport(UIKit)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        #endif
    }
    
    /// 打开 URL（带完成回调）
    public static func openURL(_ urlString: String, completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: urlString) else {
            completion?(false)
            return
        }
        #if canImport(UIKit)
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
        #endif
    }
    
    // MARK: - Send Email
    /// 发送反馈邮件
    /// - Parameters:
    ///   - to: 收件人邮箱
    ///   - subject: 邮件主题
    ///   - appName: 应用名称（用于邮件正文）
    public static func sendFeedbackEmail(
        to: String,
        subject: String,
        appName: String? = nil
    ) {
        let appVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        
        #if canImport(UIKit)
        let device = UIDevice.current.model
        let sys = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        #else
        let device = "Unknown"
        let sys = "Unknown"
        #endif
        
        let body = """
        Please describe your issue or suggestion here:

        —
        App: \(appName ?? "App") \(appVer) (\(build))
        Device: \(device)
        System: \(sys)
        """
        
        // URL 编码
        let encode: (String) -> String = { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "" }
        let urlString = "mailto:\(to)?subject=\(encode(subject))&body=\(encode(body))"
        
        openURL(urlString)
    }
    
    // MARK: - Share App
    /// 分享应用
    /// - Parameters:
    ///   - text: 分享文字
    ///   - appStoreURL: App Store 链接
    public static func shareApp(text: String, appStoreURL: String) {
        guard let url = URL(string: appStoreURL) else { return }
        
        #if canImport(UIKit)
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        if let sourceView = topMostViewController()?.view {
            activityVC.popoverPresentationController?.sourceView = sourceView
            activityVC.popoverPresentationController?.sourceRect = CGRect(
                x: sourceView.bounds.midX,
                y: sourceView.bounds.midY,
                width: 1,
                height: 1
            )
        }
        
        topMostViewController()?.present(activityVC, animated: true)
        #endif
    }
    
    // MARK: - Rate App
    /// 请求应用评价
    @MainActor
    public static func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
    
    // MARK: - Get Top ViewController
    /// 获取当前最顶层的 ViewController
    public static func topMostViewController(
        base: UIViewController? = {
            guard let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }),
                  let root = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
            else {
                return nil
            }
            return root
        }()
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
    
    // MARK: - Check App Installed
    /// 检查应用是否已安装
    /// - Parameter scheme: 应用的 URL Scheme
    /// - Returns: 是否已安装
    public static func isAppInstalled(scheme: String) -> Bool {
        #if canImport(UIKit)
        if let schemeURL = URL(string: "\(scheme)://") {
            return UIApplication.shared.canOpenURL(schemeURL)
        }
        #endif
        return false
    }
    
    // MARK: - Open App or AppStore
    /// 打开应用或跳转到 App Store
    /// - Parameters:
    ///   - deepLink: 应用的深度链接
    ///   - appStoreURL: App Store 链接
    public static func openAppOrStore(deepLink: String, appStoreURL: String) {
        #if canImport(UIKit)
        if let deepLinkURL = URL(string: deepLink) {
            UIApplication.shared.open(deepLinkURL) { success in
                if !success {
                    openURL(appStoreURL)
                }
            }
        } else {
            openURL(appStoreURL)
        }
        #endif
    }
}

// MARK: - Common URLs
/// 常用 URL 集合
public struct JetSettingsURLs {
    /// Apple 标准服务条款
    public static let appleTermsOfUse = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
}

// MARK: - App Info
/// 应用信息工具
public struct JetAppInfo {
    /// 应用版本号
    public static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
    
    /// 构建号
    public static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
    }
    
    /// 完整版本字符串
    public static var fullVersion: String {
        "\(version) (\(build))"
    }
    
    /// 应用名称
    public static var appName: String {
        Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "App"
    }
    
    #if canImport(UIKit)
    /// 设备型号
    public static var deviceModel: String {
        UIDevice.current.model
    }
    
    /// 系统版本
    public static var systemVersion: String {
        "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
    #endif
}
