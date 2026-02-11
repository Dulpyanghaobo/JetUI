//
//  JetTrialPaywallView.swift
//  JetUI
//
//  试用版 Paywall 视图 - 展示免费试用流程和价格选项
//

import SwiftUI
import StoreKit

/// 试用版 Paywall 视图
public struct JetTrialPaywallView: View {
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    
    /// 外部注入的 ViewModel（优先使用）
    private var externalViewModel: JetPaywallViewModel?
    
    /// 内部创建的 ViewModel（当未提供外部 VM 时使用）
    @StateObject private var internalViewModel = JetPaywallViewModel()
    
    /// 统一的 ViewModel 访问计算属性
    private var vm: JetPaywallViewModel {
        externalViewModel ?? internalViewModel
    }
    
    @State private var didLogView = false
    @State private var restoreTapPending = false
    @State private var isShimmering = false
    
    private let config: JetTrialPaywallConfig
    private let onSuccess: () -> Void
    private let onDismiss: (() -> Void)?
    
    // MARK: - Computed Properties
    
    private var isYearlySelected: Bool {
        guard let id = vm.selectedProductID,
              let plan = vm.plans.first(where: { $0.id == id }) else { return false }
        return plan.isYearly
    }
    
    // MARK: - Initializers
    
    /// 使用 JetTrialPaywallConfig 初始化（支持外部注入 ViewModel）
    /// - Parameters:
    ///   - viewModel: 外部传入的 ViewModel（可选，不传则创建新的）
    ///   - config: Trial Paywall 配置
    ///   - onSuccess: 购买成功回调
    ///   - onDismiss: 关闭回调
    public init(
        viewModel: JetPaywallViewModel? = nil,
        config: JetTrialPaywallConfig,
        onSuccess: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) {
        self.externalViewModel = viewModel
        self.config = config
        self.onSuccess = onSuccess
        self.onDismiss = onDismiss
    }
    
    /// 使用旧的初始化方式保持向后兼容
    /// - Parameters:
    ///   - config: Trial Paywall 配置
    ///   - subscriptionConfig: 订阅配置（已废弃，改用全局配置）
    ///   - onSuccess: 购买成功回调
    @available(*, deprecated, message: "Use init(viewModel:config:onSuccess:onDismiss:) instead")
    public init(
        config: JetTrialPaywallConfig,
        subscriptionConfig: JetSubscriptionConfig,
        onSuccess: @escaping () -> Void = {}
    ) {
        self.externalViewModel = nil
        self.config = config
        self.onSuccess = onSuccess
        self.onDismiss = nil
    }
    
    /// 使用 JetPaywallContent 初始化
    /// - Parameters:
    ///   - viewModel: 外部传入的 ViewModel（可选，不传则创建新的）
    ///   - content: 统一的内容容器
    ///   - onSuccess: 购买成功回调
    ///   - onDismiss: 关闭回调
    public init(
        viewModel: JetPaywallViewModel? = nil,
        content: JetPaywallContent,
        onSuccess: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) {
        self.externalViewModel = viewModel
        self.config = JetTrialPaywallConfig(from: content)
        self.onSuccess = onSuccess
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .top) {
            // 背景渐变
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [config.backgroundColor, .black],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 400)
                .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 24) {
                header
                
                // 动态标题
                Text(isYearlySelected ? config.trialTitle : config.lifetimeTitle)
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                // 顶部内容
                topContent
                    .padding(.bottom, 16)
                
                // 价格选项
                priceOptions
                    .padding(.top, 8)
                
                Spacer(minLength: 8)
                
                // 底部区域
                VStack(spacing: 0) {
                    renewalHint
                        .frame(height: 32, alignment: .center)
                    
                    continueButton
                    
                    legalLinks
                        .padding(.top, 4)
                }
            }
            .padding(20)
            
            if vm.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
            }
        }
        .background(.black)
        .onChange(of: vm.shouldDismissPaywall) { ok in
            if ok {
                logSuccessEvent()
                onSuccess()
                dismiss()
            }
        }
        .onAppear {
            if !didLogView {
                didLogView = true
                AnalyticsManager.logPaywallView(variant: "trial")
            }
        }
    }
}

// MARK: - Subviews

private extension JetTrialPaywallView {
    
    var header: some View {
        HStack {
            Button(action: {
                AnalyticsManager.logEvent(JetPaywallEvent.action, parameters: [
                    "action": "dismiss",
                    "source": "header_close"
                ])
                onDismiss?()
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .padding(10)
            }
            .contentShape(Rectangle())
            
            Spacer()
            
            Button(config.restoreButtonTitle) {
                AnalyticsManager.logEvent(JetPaywallEvent.action, parameters: ["action": "restore_tap"])
                restoreTapPending = true
                Task { await vm.restore() }
            }
            .font(.callout.bold())
            .padding(10)
            .disabled(vm.restoreInProgress)
            .opacity(vm.restoreInProgress ? 0.6 : 1)
        }
        .foregroundColor(.white)
    }
    
    @ViewBuilder
    var topContent: some View {
        if isYearlySelected {
            // 试用流程时间线
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(config.trialSteps.enumerated()), id: \.offset) { index, step in
                    TimelineStepRow(
                        iconName: step.iconName,
                        title: step.title,
                        message: step.message,
                        accentColor: config.accentColor,
                        isFirst: index == 0,
                        isLast: index == config.trialSteps.count - 1
                    )
                }
            }
            .frame(height: 250, alignment: .top)
        } else {
            // 功能列表
            VStack(alignment: .leading, spacing: 14) {
                ForEach(config.benefits, id: \.self) { benefit in
                    BenefitRow(
                        iconName: benefit.iconName,
                        title: benefit.title
                    )
                }
            }
            .padding(.top, 4)
            .padding(.horizontal, 10)
            .frame(height: 250, alignment: .top)
        }
    }
    
    var priceOptions: some View {
        VStack(spacing: 12) {
            ForEach(vm.plans) { plan in
                JetPriceRow(
                    title: plan.title,
                    message: plan.trialBadge ?? plan.promoBadge ?? plan.sublineText ?? "",
                    price: plan.priceText,
                    isSelected: vm.selectedProductID == plan.id,
                    cornerTag: calculateSaveTag(for: plan),
                    allowHighlight: plan.isYearly,
                    accentColor: config.accentColor
                ) {
                    AnalyticsManager.logEvent(JetPaywallEvent.optionSelect, parameters: [
                        "plan_id": plan.id,
                        "title": plan.title
                    ])
                    vm.selectedProductID = plan.id
                }
            }
        }
    }
    
    @ViewBuilder
    var renewalHint: some View {
        if let hint = vm.nextRenewalHint {
            Text(hint)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        } else {
            Text(" ")
                .font(.caption)
                .foregroundColor(.clear)
        }
    }
    
    var continueButton: some View {
        let isBusy = vm.isLoading || vm.restoreInProgress || (vm.purchaseInProgress != nil)
        let sel = vm.plans.first(where: { $0.id == vm.selectedProductID })
        
        return Button {
            AnalyticsManager.logEvent(JetPaywallEvent.action, parameters: [
                "action": "continue_tap",
                "plan_id": sel?.id ?? "none",
                "title": sel?.title ?? ""
            ])
            Task { await vm.purchaseSelected() }
        } label: {
            let title: String = {
                if isBusy { return config.processingTitle }
                if let badge = sel?.trialBadge, !badge.isEmpty {
                    if let prefix = badge.split(separator: ",").first { return String(prefix) }
                    return badge
                }
                return config.continueButtonTitle
            }()
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(config.accentColor)
                        
                        if !isBusy && vm.selectedProductID != nil {
                            shimmerEffect
                        }
                    }
                )
                .padding()
        }
        .disabled(isBusy || vm.selectedProductID == nil)
        .opacity(isBusy || vm.selectedProductID == nil ? 0.6 : 1)
    }
    
    var shimmerEffect: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.2),
                            .white.opacity(0.5),
                            .white.opacity(0.2),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .rotationEffect(.degrees(30))
                .frame(width: 80, height: geo.size.height * 3)
                .offset(x: isShimmering ? geo.size.width + 100 : -100)
                .frame(width: geo.size.width, height: geo.size.height)
                .onAppear {
                    isShimmering = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                            isShimmering = true
                        }
                    }
                }
        }
        .mask(RoundedRectangle(cornerRadius: 28))
        .allowsHitTesting(false)
    }
    
    var legalLinks: some View {
        let selected = vm.plans.first(where: { $0.id == vm.selectedProductID })
        let isLifetime = selected?.product.type == .nonConsumable
        let tip = isLifetime ? config.lifetimeTip : config.autoRenewalTip
        
        return VStack(spacing: 4) {
            Text(tip)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            HStack(spacing: 6) {
                Link(destination: config.privacyPolicyURL) {
                    Text(config.privacyPolicyTitle)
                }
                Text("·").foregroundColor(.white.opacity(0.4))
                Link(destination: config.termsURL) {
                    Text(config.termsTitle)
                }
            }
            .font(.footnote)
            .foregroundColor(.white)
        }
        .padding(.top, 8)
        .padding(.bottom, 10)
    }
    
    // MARK: - Helper Methods
    
    func calculateSaveTag(for plan: JetPlanDisplay) -> String? {
        guard plan.isYearly else { return nil }
        
        if let percent = vm.calculateSavePercentage(for: plan), percent > 0 {
            return String(format: config.savePercentFormat, percent)
        }
        return nil
    }
    
    func logSuccessEvent() {
        let sel = vm.plans.first(where: { $0.id == vm.selectedProductID })
        let action = restoreTapPending ? "restore_success" : "purchase_success"
        AnalyticsManager.logEvent(JetPaywallEvent.action, parameters: [
            "action": action,
            "plan_id": sel?.id ?? "none",
            "title": sel?.title ?? ""
        ])
        restoreTapPending = false
    }
}

// MARK: - Timeline Step Row

private struct TimelineStepRow: View {
    let iconName: String
    let title: String
    let message: String?
    let accentColor: Color
    var isFirst: Bool = false
    var isLast: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            TimelineColumn(
                iconName: iconName,
                accentColor: accentColor,
                isFirst: isFirst,
                isLast: isLast
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                if let message = message, !message.isEmpty {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(minHeight: 62)
        }
        .frame(minHeight: 80)
    }
}

private struct TimelineColumn: View {
    let iconName: String
    let accentColor: Color
    var isFirst: Bool
    var isLast: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                if !isFirst {
                    Rectangle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 8)
                        .frame(maxHeight: .infinity)
                } else {
                    Spacer(minLength: 0)
                }
                
                Spacer().frame(height: 36)
                
                if !isLast {
                    Rectangle()
                        .fill(isFirst ? accentColor : .white.opacity(0.18))
                        .frame(width: 8)
                        .frame(maxHeight: .infinity)
                } else {
                    Spacer(minLength: 0)
                }
            }
            
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .foregroundColor(accentColor)
        }
        .frame(width: 36)
    }
}

// MARK: - Benefit Row

private struct BenefitRow: View {
    let iconName: String
    let title: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            Text(title)
                .font(.body.weight(.medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .frame(minHeight: 44)
    }
}

// MARK: - Configuration

/// 试用 Paywall 配置
public struct JetTrialPaywallConfig {
    
    // MARK: - Colors
    
    public let backgroundColor: Color
    public let accentColor: Color
    
    // MARK: - Titles
    
    public let trialTitle: String
    public let lifetimeTitle: String
    public let restoreButtonTitle: String
    public let continueButtonTitle: String
    public let processingTitle: String
    
    // MARK: - Tips
    
    public let autoRenewalTip: String
    public let lifetimeTip: String
    public let savePercentFormat: String
    
    // MARK: - Legal
    
    public let privacyPolicyURL: URL
    public let privacyPolicyTitle: String
    public let termsURL: URL
    public let termsTitle: String
    
    // MARK: - Trial Steps
    
    public let trialSteps: [TrialStep]
    
    // MARK: - Benefits
    
    public let benefits: [Benefit]
    
    // MARK: - Types
    
    public struct TrialStep {
        public let iconName: String
        public let title: String
        public let message: String?
        
        public init(iconName: String, title: String, message: String? = nil) {
            self.iconName = iconName
            self.title = title
            self.message = message
        }
    }
    
    public struct Benefit: Hashable {
        public let iconName: String
        public let title: String
        
        public init(iconName: String, title: String) {
            self.iconName = iconName
            self.title = title
        }
    }
    
    // MARK: - Initializer
    
    public init(
        backgroundColor: Color = Color(red: 0.2, green: 0.1, blue: 0.3),
        accentColor: Color = .orange,
        trialTitle: String = "How Free Trial Works",
        lifetimeTitle: String = "Unlock Unlimited Access",
        restoreButtonTitle: String = "Restore",
        continueButtonTitle: String = "Continue",
        processingTitle: String = "Processing...",
        autoRenewalTip: String = "Auto-renewable. Cancel anytime.",
        lifetimeTip: String = "One-time purchase, valid for life.",
        savePercentFormat: String = "Save %d%%",
        privacyPolicyURL: URL = URL(string: "https://example.com/privacy")!,
        privacyPolicyTitle: String = "Privacy Policy",
        termsURL: URL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!,
        termsTitle: String = "Terms & Conditions",
        trialSteps: [TrialStep] = [],
        benefits: [Benefit] = []
    ) {
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.trialTitle = trialTitle
        self.lifetimeTitle = lifetimeTitle
        self.restoreButtonTitle = restoreButtonTitle
        self.continueButtonTitle = continueButtonTitle
        self.processingTitle = processingTitle
        self.autoRenewalTip = autoRenewalTip
        self.lifetimeTip = lifetimeTip
        self.savePercentFormat = savePercentFormat
        self.privacyPolicyURL = privacyPolicyURL
        self.privacyPolicyTitle = privacyPolicyTitle
        self.termsURL = termsURL
        self.termsTitle = termsTitle
        self.trialSteps = trialSteps
        self.benefits = benefits
    }
    
    // MARK: - Conversion from JetPaywallContent
    
    /// 从 JetPaywallContent 创建配置
    /// - Parameter content: 统一的内容容器
    /// - Returns: JetTrialPaywallConfig 实例
    public init(from content: JetPaywallContent) {
        self.backgroundColor = content.backgroundColor
        self.accentColor = content.accentColor
        self.trialTitle = content.brandTitle
        self.lifetimeTitle = content.brandTitle
        self.restoreButtonTitle = content.restoreText
        self.continueButtonTitle = content.continueText
        self.processingTitle = content.processingText
        self.autoRenewalTip = "Auto-renewable. Cancel anytime."
        self.lifetimeTip = "One-time purchase, valid for life."
        self.savePercentFormat = "Save %d%%"
        self.privacyPolicyURL = content.privacyPolicyURL ?? URL(string: "https://example.com/privacy")!
        self.privacyPolicyTitle = content.privacyText
        self.termsURL = content.termsURL ?? URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
        self.termsTitle = content.termsText
        
        // 转换 Timeline Steps
        self.trialSteps = content.timelineSteps.map { step in
            TrialStep(iconName: step.icon, title: step.title, message: step.subtitle)
        }
        
        // 转换 Benefits
        self.benefits = content.complexBenefits.map { benefit in
            Benefit(iconName: benefit.icon, title: benefit.title)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct JetTrialPaywallView_Previews: PreviewProvider {
    static var previews: some View {
        JetTrialPaywallView(
            config: .init(
                trialSteps: [
                    .init(iconName: "checkmark.circle", title: "Today - Full Access", message: "Start capture with Pro features"),
                    .init(iconName: "bell.circle", title: "Day 5 - Trial Reminder", message: "We'll remind you before trial ends"),
                    .init(iconName: "star.circle", title: "Day 7 - Trial Ends", message: "Subscription starts")
                ],
                benefits: [
                    .init(iconName: "star.fill", title: "Unlimited Timestamps"),
                    .init(iconName: "camera.filters", title: "Professional Filters"),
                    .init(iconName: "crown.fill", title: "All Premium Features"),
                    .init(iconName: "nosign", title: "No Ads")
                ]
            )
        )
    }
}
#endif
