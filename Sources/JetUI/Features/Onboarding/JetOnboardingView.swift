//
//  JetOnboardingView.swift
//  JetUI
//
//  通用的新手引导视图组件
//  支持自定义页面内容和样式
//

import SwiftUI

// MARK: - Page Model

/// Onboarding 页面模型
public struct JetOnboardingPage: Identifiable {
    public let id = UUID()
    
    /// 图片提供者（使用闭包，支持不同来源的图片）
    public let imageProvider: () -> Image
    
    /// 标题
    public let title: String
    
    /// 副标题
    public let subtitle: String
    
    /// 是否显示底部自定义内容
    public let showsBottomContent: Bool
    
    /// 底部自定义内容（可选）
    public let bottomContent: AnyView?
    
    public init(
        imageProvider: @escaping () -> Image,
        title: String,
        subtitle: String,
        showsBottomContent: Bool = false,
        bottomContent: AnyView? = nil
    ) {
        self.imageProvider = imageProvider
        self.title = title
        self.subtitle = subtitle
        self.showsBottomContent = showsBottomContent
        self.bottomContent = bottomContent
    }
    
    /// 便捷初始化器 - 使用 Asset 图片名
    public init(
        imageName: String,
        title: String,
        subtitle: String,
        showsBottomContent: Bool = false,
        bottomContent: AnyView? = nil
    ) {
        self.imageProvider = { Image(imageName) }
        self.title = title
        self.subtitle = subtitle
        self.showsBottomContent = showsBottomContent
        self.bottomContent = bottomContent
    }
    
    /// 便捷初始化器 - 使用 SF Symbol
    public init(
        systemImage: String,
        title: String,
        subtitle: String,
        showsBottomContent: Bool = false,
        bottomContent: AnyView? = nil
    ) {
        self.imageProvider = { Image(systemName: systemImage) }
        self.title = title
        self.subtitle = subtitle
        self.showsBottomContent = showsBottomContent
        self.bottomContent = bottomContent
    }
}

// MARK: - Configuration

/// Onboarding 视图配置
public struct JetOnboardingConfiguration {
    /// 主题色
    public let accentColor: Color
    
    /// 继续按钮文本
    public let continueButtonText: String
    
    /// 完成按钮文本
    public let finishButtonText: String
    
    /// 是否显示跳过按钮
    public let showSkipButton: Bool
    
    /// 跳过按钮文本
    public let skipButtonText: String
    
    /// 是否显示页面指示器
    public let showPageIndicator: Bool
    
    /// 文字颜色
    public let textColor: Color
    
    /// 按钮高度
    public let buttonHeight: CGFloat
    
    /// 按钮圆角
    public let buttonCornerRadius: CGFloat
    
    /// 按钮水平内边距
    public let buttonHorizontalPadding: CGFloat
    
    public init(
        accentColor: Color = .blue,
        continueButtonText: String = "Continue",
        finishButtonText: String = "Get Started",
        showSkipButton: Bool = false,
        skipButtonText: String = "Skip",
        showPageIndicator: Bool = true,
        textColor: Color = .white,
        buttonHeight: CGFloat = 52,
        buttonCornerRadius: CGFloat = 24,
        buttonHorizontalPadding: CGFloat = 48
    ) {
        self.accentColor = accentColor
        self.continueButtonText = continueButtonText
        self.finishButtonText = finishButtonText
        self.showSkipButton = showSkipButton
        self.skipButtonText = skipButtonText
        self.showPageIndicator = showPageIndicator
        self.textColor = textColor
        self.buttonHeight = buttonHeight
        self.buttonCornerRadius = buttonCornerRadius
        self.buttonHorizontalPadding = buttonHorizontalPadding
    }
    
    /// 默认配置
    public static var `default`: JetOnboardingConfiguration {
        JetOnboardingConfiguration()
    }
}

// MARK: - Onboarding View

/// 通用 Onboarding 视图
public struct JetOnboardingView<FinalPage: View>: View {
    
    /// 页面数据
    private let pages: [JetOnboardingPage]
    
    /// 配置
    private let configuration: JetOnboardingConfiguration
    
    /// 最后一页（如 Paywall）
    private let finalPage: FinalPage?
    
    /// 完成回调
    private let onFinish: () -> Void
    
    /// 页面切换回调（用于统计）
    private let onPageChange: ((Int) -> Void)?
    
    /// 当前页面索引
    @State private var pageIndex = 0
    
    // MARK: - Initializers
    
    /// 标准初始化器（无最后一页）
    public init(
        pages: [JetOnboardingPage],
        configuration: JetOnboardingConfiguration = .default,
        onPageChange: ((Int) -> Void)? = nil,
        onFinish: @escaping () -> Void
    ) where FinalPage == EmptyView {
        self.pages = pages
        self.configuration = configuration
        self.finalPage = nil
        self.onPageChange = onPageChange
        self.onFinish = onFinish
    }
    
    /// 带最后一页的初始化器
    public init(
        pages: [JetOnboardingPage],
        configuration: JetOnboardingConfiguration = .default,
        @ViewBuilder finalPage: () -> FinalPage,
        onPageChange: ((Int) -> Void)? = nil,
        onFinish: @escaping () -> Void
    ) {
        self.pages = pages
        self.configuration = configuration
        self.finalPage = finalPage()
        self.onPageChange = onPageChange
        self.onFinish = onFinish
    }
    
    // MARK: - Body
    
    public var body: some View {
        TabView(selection: $pageIndex) {
            // Onboarding 页面
            ForEach(pages.indices, id: \.self) { index in
                OnboardingPageView(
                    page: pages[index],
                    configuration: configuration
                )
                .tag(index)
                .ignoresSafeArea()
                .onAppear {
                    onPageChange?(index)
                }
            }
            
            // 最后一页（如 Paywall）
            if let finalPage = finalPage {
                finalPage
                    .tag(pages.count)
                    .ignoresSafeArea()
                    .onAppear {
                        onPageChange?(pages.count)
                    }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: pageIndex)
        .overlay(alignment: .bottom) {
            if shouldShowCTAButton {
                ctaButton
            }
        }
        .overlay(alignment: .topTrailing) {
            if configuration.showSkipButton && pageIndex < totalPages - 1 {
                skipButton
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Private Properties
    
    private var totalPages: Int {
        finalPage != nil ? pages.count + 1 : pages.count
    }
    
    private var shouldShowCTAButton: Bool {
        // 如果有最后一页，只在 Onboarding 页面显示 CTA
        if finalPage != nil {
            return pageIndex < pages.count
        }
        // 否则所有页面都显示
        return true
    }
    
    private var isLastOnboardingPage: Bool {
        if finalPage != nil {
            return pageIndex == pages.count - 1
        }
        return pageIndex == pages.count - 1
    }
    
    // MARK: - Subviews
    
    private var ctaButton: some View {
        Button {
            withAnimation(.easeInOut) {
                if isLastOnboardingPage && finalPage == nil {
                    onFinish()
                } else {
                    pageIndex += 1
                }
            }
        } label: {
            Text(isLastOnboardingPage && finalPage == nil ? configuration.finishButtonText : configuration.continueButtonText)
                .font(.headline.bold())
                .frame(maxWidth: .infinity)
                .frame(height: configuration.buttonHeight)
                .background(configuration.accentColor)
                .foregroundColor(.white)
                .cornerRadius(configuration.buttonCornerRadius)
                .padding(.horizontal, configuration.buttonHorizontalPadding)
        }
        .padding(.bottom, 64)
    }
    
    private var skipButton: some View {
        Button {
            if finalPage != nil {
                pageIndex = pages.count
            } else {
                onFinish()
            }
        } label: {
            Text(configuration.skipButtonText)
                .font(.subheadline)
                .foregroundColor(configuration.textColor.opacity(0.8))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
        }
        .padding(.top, 60)
        .padding(.trailing, 16)
    }
}

// MARK: - Page View

private struct OnboardingPageView: View {
    let page: JetOnboardingPage
    let configuration: JetOnboardingConfiguration
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                // 背景图片
                page.imageProvider()
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                
                // 文字层
                VStack(spacing: 8) {
                    Text(page.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .foregroundColor(configuration.textColor)
                        .padding(.horizontal, 16)
                    
                    Text(page.subtitle)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(configuration.textColor)
                        .padding(.horizontal, 24)
                }
                .frame(width: geo.size.width)
                .padding(.top, 64)
                
                // 底部自定义内容
                if page.showsBottomContent, let content = page.bottomContent {
                    content
                        .padding(.bottom, 128 + 64)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct JetOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        JetOnboardingView(
            pages: [
                JetOnboardingPage(
                    systemImage: "camera.fill",
                    title: "Welcome",
                    subtitle: "Take photos with timestamps"
                ),
                JetOnboardingPage(
                    systemImage: "map.fill",
                    title: "Location",
                    subtitle: "Add location to your photos"
                )
            ],
            configuration: .init(accentColor: .orange)
        ) {
            print("Finished")
        }
    }
}
#endif