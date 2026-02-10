//
//  JetPaywallView.swift
//  JetUI
//
//  通用付费墙视图 - 支持配置化的订阅页面
//

import SwiftUI
import StoreKit

// MARK: - Paywall Configuration

/// Paywall 视图配置
public struct JetPaywallConfiguration {
    /// 主题色
    public let accentColor: Color
    
    /// 标题（品牌名）
    public let brandTitle: String
    
    /// 高亮关键词
    public let highlightKeyword: String?
    
    /// 功能点列表
    public let benefits: [String]
    
    /// 背景图片名
    public let backgroundImageName: String?
    
    /// 恢复按钮文本
    public let restoreText: String
    
    /// 继续按钮文本
    public let continueText: String
    
    /// 处理中文本
    public let processingText: String
    
    /// 重试文本
    public let retryText: String
    
    /// 加载失败文本
    public let loadFailedText: String
    
    /// 自动续订提示
    public let autoRenewHint: String
    
    /// 隐私政策 URL
    public let privacyPolicyURL: URL?
    
    /// 使用条款 URL
    public let termsURL: URL?
    
    /// 隐私政策文本
    public let privacyPolicyText: String
    
    /// 使用条款文本
    public let termsText: String
    
    /// 保存百分比格式化
    public let savePercentFormat: (Int) -> String
    
    public init(
        accentColor: Color = .orange,
        brandTitle: String = "PRO",
        highlightKeyword: String? = nil,
        benefits: [String] = [],
        backgroundImageName: String? = nil,
        restoreText: String = "Restore",
        continueText: String = "Continue",
        processingText: String = "Processing...",
        retryText: String = "Retry",
        loadFailedText: String = "Failed to load products",
        autoRenewHint: String = "Auto-renewable. Cancel anytime.",
        privacyPolicyURL: URL? = nil,
        termsURL: URL? = nil,
        privacyPolicyText: String = "Privacy Policy",
        termsText: String = "Terms of Service",
        savePercentFormat: @escaping (Int) -> String = { "Save \($0)%" }
    ) {
        self.accentColor = accentColor
        self.brandTitle = brandTitle
        self.highlightKeyword = highlightKeyword
        self.benefits = benefits
        self.backgroundImageName = backgroundImageName
        self.restoreText = restoreText
        self.continueText = continueText
        self.processingText = processingText
        self.retryText = retryText
        self.loadFailedText = loadFailedText
        self.autoRenewHint = autoRenewHint
        self.privacyPolicyURL = privacyPolicyURL
        self.termsURL = termsURL
        self.privacyPolicyText = privacyPolicyText
        self.termsText = termsText
        self.savePercentFormat = savePercentFormat
    }
    
    public static var `default`: JetPaywallConfiguration {
        JetPaywallConfiguration()
    }
}

// MARK: - Paywall View

/// 通用付费墙视图
public struct JetPaywallView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var internalViewModel: JetPaywallViewModel
    private var externalViewModel: JetPaywallViewModel?
    
    private var viewModel: JetPaywallViewModel {
        externalViewModel ?? internalViewModel
    }
    
    private let configuration: JetPaywallConfiguration
    private let onSuccess: () -> Void
    private let onDismiss: (() -> Void)?
    
    @State private var isShimmering = false
    
    private let headerHeight: CGFloat = 52
    private let contentMaxWidth: CGFloat = 560
    
    // MARK: - Initializers
    
    /// 使用外部 ViewModel 初始化
    /// - Parameters:
    ///   - viewModel: 外部传入的 ViewModel
    ///   - configuration: Paywall 配置
    ///   - onSuccess: 购买成功回调
    ///   - onDismiss: 关闭回调
    public init(
        viewModel: JetPaywallViewModel,
        configuration: JetPaywallConfiguration = .default,
        onSuccess: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) {
        self.externalViewModel = viewModel
        self._internalViewModel = StateObject(wrappedValue: viewModel)
        self.configuration = configuration
        self.onSuccess = onSuccess
        self.onDismiss = onDismiss
    }
    
    /// 使用默认 ViewModel 和全局配置初始化
    /// 需要先调用 JetUI.configureSubscription 和 JetUI.configurePaywall
    /// - Parameters:
    ///   - onSuccess: 购买成功回调
    ///   - onDismiss: 关闭回调
    public init(
        onSuccess: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) {
        let config = JetUI.subscriptionConfig ?? .empty
        self._internalViewModel = StateObject(wrappedValue: JetPaywallViewModel(config: config))
        self.externalViewModel = nil
        self.configuration = JetUI.paywallConfiguration ?? .default
        self.onSuccess = onSuccess
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top + 42
            let bottomInset = proxy.safeAreaInsets.bottom
            let heroH = min(max(proxy.size.height * 0.38, 240), 420)
            
            ZStack(alignment: .top) {
                // 背景
                Color.black.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Hero 区域
                        heroSection(heroH: heroH, topPadding: topInset + headerHeight)
                        
                        // 功能点列表
                        if !configuration.benefits.isEmpty {
                            benefitList
                                .frame(maxWidth: contentMaxWidth)
                                .padding(.horizontal, 40)
                                .padding(.top, -topInset - 16)
                        }
                        
                        // 价格选项
                        priceOptions
                            .frame(maxWidth: contentMaxWidth)
                            .padding(.horizontal, 20)
                        
                        // 底部空间
                        Spacer(minLength: 96)
                    }
                }
                .coordinateSpace(name: "paywallScroll")
                
                // 固定顶栏
                headerBar
                    .frame(height: headerHeight)
                    .frame(maxWidth: .infinity)
                    .padding(.top, topInset)
                    .padding(.horizontal, 16)
            }
            // 固定底部
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    continueButton
                        .frame(maxWidth: contentMaxWidth)
                    
                    legalLinks
                        .frame(maxWidth: contentMaxWidth)
                        .padding(.horizontal, 20)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, max(16, bottomInset))
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.9)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
            }
            .onChange(of: viewModel.shouldDismissPaywall) { shouldDismiss in
                if shouldDismiss {
                    onSuccess()
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Hero Section
    
    @ViewBuilder
    private func heroSection(heroH: CGFloat, topPadding: CGFloat) -> some View {
        ZStack(alignment: .top) {
            GeometryReader { g in
                let y = g.frame(in: .named("paywallScroll")).minY
                let pullDown = max(0, y)
                let maxExtra: CGFloat = 0.30
                let scale = 1 + min(maxExtra, (abs(y) / heroH) * maxExtra)
                
                Group {
                    if let imageName = configuration.backgroundImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        LinearGradient(
                            colors: [configuration.accentColor.opacity(0.3), Color.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .scaleEffect(scale, anchor: .top)
                .offset(y: -pullDown)
                .overlay(
                    LinearGradient(
                        colors: [Color.black.opacity(0.0), Color.black.opacity(0.85)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .clipped()
            }
            .frame(height: heroH)
            
            // 品牌标题
            brandTitleView
                .padding(.horizontal, 20)
                .padding(.top, topPadding)
        }
    }
    
    @ViewBuilder
    private var brandTitleView: some View {
        if let keyword = configuration.highlightKeyword {
            HStack(spacing: 0) {
                Text(configuration.brandTitle.replacingOccurrences(of: keyword, with: ""))
                    .foregroundColor(.white)
                Text(keyword)
                    .foregroundColor(configuration.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(cornerRadius: 6).fill(Color.black))
            }
            .font(.system(size: 40, weight: .bold))
        } else {
            Text(configuration.brandTitle)
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Header
    
    private var headerBar: some View {
        HStack {
            Button(action: { handleClose() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .padding(10)
            }
            .contentShape(Rectangle())
            
            Spacer()
            
            Button(configuration.restoreText) {
                Task { await viewModel.restore() }
            }
            .font(.callout.bold())
            .padding(10)
            .disabled(viewModel.restoreInProgress)
        }
        .foregroundColor(.white)
    }
    
    private func handleClose() {
        onDismiss?()
        dismiss()
    }
    
    // MARK: - Benefits
    
    private var benefitList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(configuration.benefits, id: \.self) { benefit in
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(configuration.accentColor)
                        .font(.system(size: 16))
                    Text(benefit)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Price Options
    
    private var priceOptions: some View {
        VStack(spacing: 12) {
            if viewModel.isLoading {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 80)
                        .shimmer()
                }
            } else if viewModel.plans.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.plans) { plan in
                    JetPriceRow(
                        title: plan.title,
                        message: plan.sublineText ?? plan.trialBadge ?? "",
                        price: plan.priceText,
                        isSelected: viewModel.selectedProductID == plan.id,
                        cornerTag: calculateSaveTag(for: plan),
                        allowHighlight: plan.isYearly,
                        accentColor: configuration.accentColor
                    ) {
                        viewModel.selectedProductID = plan.id
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.5))
            Text(viewModel.errorMessage ?? configuration.loadFailedText)
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button(configuration.retryText) {
                Task { await viewModel.load() }
            }
            .font(.headline)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(configuration.accentColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.vertical, 40)
    }
    
    private func calculateSaveTag(for plan: JetPlanDisplay) -> String? {
        guard let percent = viewModel.calculateSavePercentage(for: plan) else {
            return nil
        }
        return configuration.savePercentFormat(percent)
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        let isBusy = viewModel.isLoading || viewModel.restoreInProgress || (viewModel.purchaseInProgress != nil)
        let selected = viewModel.plans.first(where: { $0.id == viewModel.selectedProductID })
        
        return Button {
            Task { await viewModel.purchaseSelected() }
        } label: {
            let title: String = {
                if isBusy { return configuration.processingText }
                if let badge = selected?.trialBadge, !badge.isEmpty {
                    if let prefix = badge.split(separator: ",").first { return String(prefix) }
                    return badge
                }
                return configuration.continueText
            }()
            
            Text(title)
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(configuration.accentColor)
                        
                        // 扫光效果
                        if !isBusy && viewModel.selectedProductID != nil {
                            shimmerOverlay
                        }
                    }
                )
                .padding()
        }
        .disabled(isBusy || viewModel.selectedProductID == nil)
        .opacity(isBusy || viewModel.selectedProductID == nil ? 0.6 : 1)
    }
    
    private var shimmerOverlay: some View {
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
    
    // MARK: - Legal Links
    
    private var legalLinks: some View {
        let selected = viewModel.plans.first(where: { $0.id == viewModel.selectedProductID })
        let tip = selected?.sublineText ?? configuration.autoRenewHint
        
        return VStack(spacing: 6) {
            Text(tip)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 6) {
                if let url = configuration.privacyPolicyURL {
                    Link(destination: url) {
                        Text(configuration.privacyPolicyText)
                    }
                }
                if configuration.privacyPolicyURL != nil && configuration.termsURL != nil {
                    Text("·").foregroundColor(.white.opacity(0.4))
                }
                if let url = configuration.termsURL {
                    Link(destination: url) {
                        Text(configuration.termsText)
                    }
                }
            }
            .font(.footnote)
            .foregroundColor(.white)
        }
        .padding(.top, 4)
        .padding(.bottom, 2)
    }
}

// MARK: - Shimmer Modifier

private extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}
