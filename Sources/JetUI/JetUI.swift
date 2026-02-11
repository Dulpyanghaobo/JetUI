//
//  JetUI.swift
//  JetUI
//
//  JetUI 是一个 iOS UI 组件库，提供：
//  - 主题系统（AppFont, AppColor）
//  - 核心工具（Logger, Cache, Resilience, Utilities）
//  - 网络层（NetworkCore, Auth, Account）
//  - 认证管理（AuthManager）
//  - Firebase 服务（Analytics, Storage）
//  - UI 组件（Toast, Alert, Glass, Switch, Lottie, Image）
//  - 系统扩展（UIImage+Jet, View+Jet）
//  - 功能模块（Settings, Subscription, Onboarding, Feedback*）
//
//  * 计划中的模块
//

import Foundation

// MARK: - Version

public enum JetUI {
    /// 库版本号
    public static let version = "2.0.0"

    public static var subscriptionConfig: JetSubscriptionConfig?

    public static var paywallConfiguration: JetPaywallConfiguration?
    
    /// 配置日志 subsystem
    /// - Parameter subsystem: Bundle identifier 或自定义 subsystem
    public static func configureLogger(subsystem: String) {
        CSLogger.subsystem = subsystem
    }
    
    /// 配置认证 API
    /// - Parameter configuration: API 配置
    public static func configureAuth(_ configuration: APIConfiguration) {
        AuthTarget.configuration = configuration
        NetworkCore.shared.authSession = AuthSession.shared
    }
    
    /// 配置账户 API
    /// - Parameters:
    ///   - baseURL: API 服务器地址
    ///   - tokenProvider: 获取当前 Token 的闭包
    public static func configureAccount(baseURL: URL, tokenProvider: (() -> String?)?) {
        AccountTarget.configuration = DefaultAccountAPIConfiguration(
            baseURL: baseURL,
            tokenProvider: tokenProvider
        )
    }
    
    /// 配置分析系统
    /// - Parameter enabled: 是否启用分析
    public static func configureAnalytics(enabled: Bool = true) {
        AnalyticsManager.isEnabled = enabled
    }
    
    /// 配置 MemoryMonitor 的分析回调
    /// - Parameter analyticsLogger: 分析日志回调
    public static func configureMemoryMonitor(analyticsLogger: ((String, [String: Any]) -> Void)?) {
        MemoryMonitor.shared.analyticsLogger = analyticsLogger
    }
    
    /// 配置 CacheManager 的日志回调
    /// - Parameter logger: 日志回调
    @MainActor
    public static func configureCacheManager(logger: ((String) -> Void)?) {
        CacheManager.shared.logger = logger
    }
    
    /// 配置订阅服务
    /// - Parameters:
    ///   - config: 订阅配置
    ///   - paywallConfig: Paywall 视图配置（可选）
    @MainActor
    public static func configureSubscription(
        _ config: JetSubscriptionConfig,
        paywallConfiguration: JetPaywallConfiguration? = nil
    ) {
        subscriptionConfig = config
        self.paywallConfiguration = paywallConfiguration
        _ = JetSubscriptionManager()
    }
    
    /// 单独配置 Paywall 视图
    /// - Parameter configuration: Paywall 视图配置
    @MainActor
    public static func configurePaywall(_ configuration: JetPaywallConfiguration) {
        paywallConfiguration = configuration
    }
}

// MARK: - Module Documentation

/*
 JetUI 模块结构 (v2.0)：
 
 📁 Core/                          # 核心基础设施层
    📁 Logger/
       - CSLogger.swift            : 统一日志系统
    📁 Cache/
       - CacheManager.swift        : 通用缓存管理（支持 TTL、内存+持久化）
    📁 Resilience/
       - CircuitBreaker.swift      : 熔断器模式（防止级联故障）
       - MemoryMonitor.swift       : 内存监控工具
    📁 Utilities/
       - JetDateFormatter.swift    : 日期格式化工具
       - StateHelpers.swift        : SwiftUI 状态更新辅助函数
       - JetAssetSaver.swift       : 图片资源保存工具
 
 📁 Extensions/                    # 系统类型扩展
    - UIImage+Jet.swift            : UIImage 扩展（裁剪、缩放、着色）
    - View+Jet.swift               : SwiftUI View 扩展（返回按钮、条件修饰器）
 
 📁 Theme/                         # 主题系统
    - AppFont.swift                : 字体定义
    - AppColor.swift               : 颜色定义
 
 📁 Components/                    # UI 组件库
    📁 Toast/
       - JetToastView.swift        : Toast 通知组件 + ToastManager
    📁 Alert/
       - JetTextFieldAlert.swift   : 输入弹窗扩展
       - JetCustomAlertView.swift  : 自定义弹窗组件
    📁 Glass/
       - JetGlassBackground.swift  : 毛玻璃背景组件 + JetBlurView
    📁 Switch/
       - JetCustomSwitch.swift     : 自定义开关组件
    📁 Lottie/
       - JetLottieView.swift       : Lottie 动画封装
    📁 Image/
       - JetCacheAsyncImage.swift  : 带缓存的异步图片组件
 
 📁 Network/                       # 网络层
    📁 Core/
       - NetworkCore.swift         : Moya 网络核心
       - NetworkError.swift        : 错误类型
       - APIResponse.swift         : 响应模型
    📁 Auth/
       - AuthTarget.swift          : 认证 API 端点
       - AuthSession.swift         : Token 管理
       - AuthModels.swift          : 认证数据模型
    📁 Account/
       - AccountTarget.swift       : 账户/订阅 API 端点
       - AccountService.swift      : 账户/订阅 Service 层
       - LoginResult.swift         : 登录结果模型
 
 📁 Auth/                          # 认证管理
    - AuthManager.swift            : 统一认证管理器
 
 📁 Firebase/                      # Firebase 服务层
    📁 Analytics/
       - AnalyticsManager.swift    : 分析系统（Firebase Analytics）
    📁 Storage/
       - JetStorageManager.swift   : Firebase Storage 统一管理器
 
 📁 Features/                      # 功能模块
    📁 Settings/                   # 设置模块
       - JetSettingsView.swift     : 可配置样式的设置页面
       - JetSimpleSettingsView.swift: 简化版设置页面
       - JetSettingsConfiguration.swift: 配置协议与实现
       - JetSettingsPresets.swift  : 预设配置
       - JetSettingsActions.swift  : 常用操作
       - JetMembershipCardView.swift: 会员卡组件
       - JetRecommendationsView.swift: 推荐应用组件
       - JetSettingItemRow.swift   : 设置项行组件
       - JetAppConfig.swift        : App 配置
       - README.md                 : 使用文档
    📁 Subscription/               # 订阅模块
       - JetSubscriptionConfig.swift: 订阅配置（产品 ID、验证端点）
       - JetSubscriptionManager.swift: 订阅管理器（Pro 状态）
       - JetStoreService.swift     : StoreKit 服务层
       📁 Core/
          - JetKeychainStore.swift : Keychain 安全存储工具
          - JetEntitlementCache.swift: 订阅权益缓存模型
          - JetTransactionObserver.swift: 交易观察器
       📁 ViewModels/
          - JetPaywallViewModel.swift: Paywall 视图模型
       📁 Views/
          - JetPaywallView.swift   : 通用付费墙视图
          - JetTrialPaywallView.swift: 试用版付费墙视图
          - JetPriceRow.swift      : 价格选项行组件
    📁 Onboarding/                 # 引导模块
       - JetOnboardingView.swift   : 引导页视图
    📁 Feedback/                   # 反馈模块（计划中）
 
 📁 Models/                        # 共享数据模型
    - JetAppItem.swift             : App 推荐项模型
    - JetAppItem+Presets.swift     : 预设 App 配置
 
 📁 Resources/                     # 资源文件
    📁 Media.xcassets/             : 图片资源
 
 使用示例：
 
 ```swift
 import JetUI
 
 // 1. 配置
 JetUI.configureLogger(subsystem: "com.myapp")
 JetUI.configureAuth(MyAPIConfig())
 JetUI.configureAccount(
     baseURL: URL(string: "https://api.example.com")!,
     tokenProvider: { AuthManager.shared.currentLoginResult?.token }
 )
 
 // 2. 使用主题
 Text("Hello")
     .font(AppFont.body)
     .foregroundColor(AppColor.primary)
 
 // 3. 日志
 CSLogger.info("App started", category: .general)
 
 // 4. 缓存管理
 await CacheManager.shared.set(key: "user", value: userData, ttl: 3600)
 let cached = await CacheManager.shared.get(key: "user", as: UserData.self)
 
 // 5. 熔断器
 let breaker = CircuitBreakerRegistry.shared.breaker(for: "api")
 let result = try await breaker.execute {
     try await apiCall()
 }
 
 // 6. 内存监控
 MemoryMonitor.logMemoryUsage(tag: "AppLaunch")
 let report = MemoryMonitor.generateReport()
 
 // 7. Toast 通知
 Text("Content")
     .toast(message: "保存成功", type: .success, isPresented: $showToast)
 
 // 8. 状态辅助
 setIfChanged(&count, newCount)
 
 // 9. 毛玻璃背景
 VStack { content }
     .glassBackground(cornerRadius: 16)
 
 // 10. 自定义开关
 JetCustomSwitch(isOn: $isEnabled)
 
 // 11. Lottie 动画
 JetLottieView(filename: "animation", loopMode: .loop)
 
 // 12. 设置页面
 JetSettingsView(
     title: "Settings",
     theme: .dark,
     rowStyle: .darkCard,
     sections: [
         JetSettingSection(
             header: "General",
             items: [
                 JetSettingItem(icon: .system("gear"), title: "Preferences", action: {}),
             ]
         )
     ]
 )
 
 // 13. 订阅模块
 // 配置
 let config = JetSubscriptionConfig(
     productIds: ["com.app.weekly", "com.app.yearly"],
     proProductIds: ["com.app.weekly", "com.app.yearly"],
     groupId: "12345678",
     appIdentifier: "MyApp"
 )
 JetUI.configureSubscription(config)
 
 // 检查 Pro 状态
 let isPro = await JetSubscriptionManager.shared.isPro
 
 // 显示 Paywall
 let viewModel = JetPaywallViewModel(config: config)
 JetPaywallView(
     viewModel: viewModel,
     configuration: JetPaywallConfiguration(
         accentColor: .orange,
         brandTitle: "App PRO",
         highlightKeyword: "PRO",
         benefits: [
             "Unlimited access",
             "Premium features",
             "No ads"
         ],
         privacyPolicyURL: URL(string: "https://example.com/privacy"),
         termsURL: URL(string: "https://example.com/terms")
     ),
     onSuccess: {
         // 购买成功回调
     }
 )
 ```
 
 核心组件说明：
 
 ## CacheManager
 - 支持 TTL（过期时间）
 - 内存缓存 + 可选持久化（UserDefaults）
 - 自动清理过期条目
 - 线程安全
 
 ## CircuitBreaker
 - 熔断器模式防止级联故障
 - 支持 closed/open/half-open 状态
 - 可配置失败阈值和恢复超时
 
 ## MemoryMonitor
 - 实时内存使用量监控
 - 内存压力等级检测
 - 代码块性能分析（profile）
 
 ## JetToastView & ToastManager
 - 支持 success/error/warning/info 四种类型
 - View 修饰器方式 + 全局单例方式
 
 ## JetGlassBackground
 - 毛玻璃/玻璃拟态背景效果
 - 支持自定义圆角、模糊样式
 
 ## JetSettingsView
 - 支持多种主题风格（dark/light/standard）
 - 支持多种行样式（darkCard/lightCard/standard）
 - 完全可配置的设置页面组件
 
 ## UIImage+Jet
 - jet_cropped(to:) 按比例裁剪
 - jet_downsampled(from:maxPixel:) 降采样
 - jet_tinted(_:) 着色
 - jet_resized(to:) 缩放
 - jet_fixedOrientation() 方向修正
 - jet_jpegData(targetKB:) 智能压缩
 
 ## View+Jet
 - jet_backArrow() 统一返回按钮
 - jet_if() 条件修饰器
 - jet_ifLet() 可选值修饰器
 - jet_fillMaxSize() 填充布局
 - jet_border() 圆角边框
 - jet_cardShadow() 卡片阴影
 
 ## JetSubscriptionManager
 - isPro 属性检查会员状态
 - refreshProStatus() 刷新状态
 - observeTransactions() 监听交易
 
 ## JetPaywallView
 - 通用付费墙视图组件
 - 支持多种价格计划
 - 自动计算节省百分比
 - 免费试用 Badge
 - 扫光按钮动画
 - 可配置品牌、颜色、文案
 
 ## JetStorageManager
 - uploadImage() 上传图片
 - downloadImage() 下载图片
 - fetchAllImageNames() 列出所有文件
 - deleteImage() 删除文件
 - getMetadata() 获取文件元数据
 - getDownloadURL() 获取下载 URL
*/
