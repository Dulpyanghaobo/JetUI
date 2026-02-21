//
//  JetPaywall.swift
//  JetUI
//
//  统一的 Paywall 入口视图 - 根据风格分发到对应的子视图
//

import SwiftUI

/// 统一的 Paywall 入口视图
///
/// 这是外部调用订阅模块的唯一接口，根据传入的 `style` 参数自动分发到对应的 UI 风格。
///
/// ## 使用示例
///
/// ```swift
/// // List 风格
/// JetPaywall(
///     style: .list,
///     content: JetPaywallContent.defaultList,
///     onSuccess: { print("购买成功") }
/// )
///
/// // Timeline 风格
/// JetPaywall(
///     style: .timeline,
///     content: JetPaywallContent.defaultTimeline,
///     onSuccess: { print("购买成功") }
/// )
/// ```
public struct JetPaywall: View {
    
    // MARK: - Properties
    
    /// UI 风格
    private let style: JetPaywallStyle
    
    /// 内容配置
    private let content: JetPaywallContent
    
    /// 购买成功回调
    private let onSuccess: () -> Void
    
    /// 关闭回调
    private let onDismiss: (() -> Void)?
    
    /// 共享的 ViewModel（在此持有 StateObject）
    @StateObject private var viewModel = JetPaywallViewModel()
    
    // MARK: - Initializer
    public init(
        style: JetPaywallStyle,
        content: JetPaywallContent,
        onSuccess: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) {
        self.style = style
        self.content = content
        self.onSuccess = onSuccess
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    public var body: some View {
        switch style {
        case .list:
            JetPaywallView(
                viewModel: viewModel,
                content: content,
                onSuccess: onSuccess,
                onDismiss: onDismiss
            )
            
        case .timeline:
            JetTrialPaywallView(
                viewModel: viewModel,
                content: content,
                onSuccess: onSuccess,
                onDismiss: onDismiss
            )
        }
    }
}

// MARK: - Convenience Initializers

extension JetPaywall {
    
    /// 使用默认的 List 风格创建 Paywall
    /// - Parameters:
    ///   - content: 内容配置（默认使用 defaultList）
    ///   - onSuccess: 购买成功回调
    ///   - onDismiss: 关闭回调
    /// - Returns: JetPaywall 实例
    public static func list(
        content: JetPaywallContent = .defaultList,
        onSuccess: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) -> JetPaywall {
        JetPaywall(
            style: .list,
            content: content,
            onSuccess: onSuccess,
            onDismiss: onDismiss
        )
    }
    
    /// 使用默认的 Timeline 风格创建 Paywall
    /// - Parameters:
    ///   - content: 内容配置（默认使用 defaultTimeline）
    ///   - onSuccess: 购买成功回调
    ///   - onDismiss: 关闭回调
    /// - Returns: JetPaywall 实例
    public static func timeline(
        content: JetPaywallContent = .defaultTimeline,
        onSuccess: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) -> JetPaywall {
        JetPaywall(
            style: .timeline,
            content: content,
            onSuccess: onSuccess,
            onDismiss: onDismiss
        )
    }
}
