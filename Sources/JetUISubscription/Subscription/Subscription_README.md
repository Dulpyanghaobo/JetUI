# JetSubscription Library

**JetSubscription** 是一个基于 **StoreKit 2** 的轻量级、模块化 iOS 订阅管理库。它提供了从底层收据验证、本地安全缓存到现成的高颜值 Paywall UI 的一站式解决方案。

## 📋 目录

- [核心特性](#-核心特性)
- [快速开始](#-快速开始-quick-start)
- [使用 Paywall](#-使用-paywall-ui)
- [本地化支持](#-本地化支持-localization)
- [Analytics 埋点](#-analytics-埋点)
- [架构说明](#-架构说明)
- [优化建议](#-优化建议)
- [注意事项](#️-注意事项)

---

## ✨ 核心特性

* **StoreKit 2 Native**: 完全基于现代 Swift Concurrency (async/await) 和 StoreKit 2 API。
* **安全缓存**: 使用 Keychain 存储订阅状态 (`JetEntitlementCache`)，确保卸载重装或离线状态下权益不丢失。
* **自动监听**: `JetTransactionObserver` 在后台自动处理续订、退款和购买更新。
* **UI 组件化**: 提供通用的 `JetPaywallView` 和试用引导专用的 `JetTrialPaywallView`。
* **高度可配置**: 支持自定义 Paywall 文案、颜色、功能点列表和背景。
* **Analytics 支持**: 内置埋点协议，轻松对接 Firebase 或 Mixpanel。

---

## 🛠 快速开始 (Quick Start)

### 1. 准备配置 (Configuration)

首先，定义你的订阅配置。这通常在 App 启动时完成。

```swift
import JetUI // 假设你的库包含在 JetUI 模块中

// 定义你的产品 ID
let config = JetSubscriptionConfig(
    productIds: ["com.app.monthly", "com.app.yearly", "com.app.lifetime"],
    proProductIds: Set(["com.app.monthly", "com.app.yearly", "com.app.lifetime"]), // 这些 ID 激活 Pro 权益
    groupId: "21345678", // App Store Connect 中的订阅组 ID
    appIdentifier: "com.yourcompany.app",
    familySharingEnabled: true
)

```

### 2. 启动服务 (Bootstrap)

在 `AppDelegate` 或 `App` 的初始化阶段，使用 `JetIAPBootstrap` 启动监听服务。建议将其保存为单例或注入到环境中，确保生命周期与 App 一致。

```swift
class SubscriptionService {
    static let shared = SubscriptionService()
    
    let bootstrap: JetIAPBootstrap
    
    private init() {
        // 1. 创建配置
        let config = JetSubscriptionConfig(
            productIds: ["tier1.monthly", "tier1.yearly"],
            proProductIds: ["tier1.monthly", "tier1.yearly"],
            groupId: "123456",
            appIdentifier: "com.example.app"
        )
        
        // 2. 初始化 Bootstrap
        self.bootstrap = JetIAPBootstrap(config: config)
    }
    
    func start() {
        // 3. 开始监听 StoreKit 交易队列并刷新缓存
        bootstrap.start()
    }
    
    // 检查用户是否是 Pro
    var isPro: Bool {
        bootstrap.isPro()
    }
}

// 在 App 入口调用
@main
struct MyApp: App {
    init() {
        SubscriptionService.shared.start()
    }
    
    var body: some Scene { ... }
}

```

### 3. 检查权益 (Check Entitlement)

由于使用了 Keychain 缓存，你可以同步检查用户是否拥有 Pro 权限，无需等待网络请求。

```swift
if SubscriptionService.shared.isPro {
    // 显示高级功能
} else {
    // 显示锁或 Paywall
}

```

---

## 📱 使用 Paywall (UI)

该库提供了两种风格的 Paywall，均支持 SwiftUI。

### 方式 A: 通用 Paywall (`JetPaywallView`)

适用于大多数标准的订阅展示页面。

```swift
import SwiftUI

struct SettingsView: View {
    @State private var showPaywall = false
    
    var body: some View {
        Button("Upgrade to Pro") {
            showPaywall = true
        }
        .sheet(isPresented: $showPaywall) {
            // 1. 创建 ViewModel
            let viewModel = JetPaywallViewModel(config: yourConfig)
            
            // 2. 配置 UI 外观
            let uiConfig = JetPaywallConfiguration(
                accentColor: .blue,
                brandTitle: "Unlock PRO",
                benefits: [
                    "Unlimited Access",
                    "No Ads",
                    "4K Export"
                ],
                privacyPolicyURL: URL(string: "https://...")!,
                termsURL: URL(string: "https://...")!
            )
            
            // 3. 显示视图
            JetPaywallView(
                viewModel: viewModel,
                configuration: uiConfig,
                onSuccess: {
                    print("购买成功！")
                    //在这里处理解锁逻辑或关闭页面
                },
                onDismiss: {
                    print("用户关闭了页面")
                }
            )
        }
    }
}

```

### 方式 B: 试用引导 Paywall (`JetTrialPaywallView`)

适用于首次安装或强调“免费试用”流程的场景，带有时间轴视图。

```swift
let trialConfig = JetTrialPaywallConfig(
    backgroundColor: Color.black,
    accentColor: .yellow,
    trialTitle: "Start Your Free Trial",
    trialSteps: [
        .init(iconName: "lock.open", title: "Today", message: "Instant access to all features"),
        .init(iconName: "bell", title: "Day 5", message: "Reminder email before trial ends"),
        .init(iconName: "star", title: "Day 7", message: "Trial converts to subscription")
    ],
    benefits: [
        .init(iconName: "infinity", title: "Unlimited Scans"),
        .init(iconName: "cloud", title: "Cloud Sync")
    ]
)

JetTrialPaywallView(
    config: trialConfig,
    subscriptionConfig: yourConfig,
    onSuccess: {
        // 试用开启成功
    }
)

```

---

## 📊 Analytics (埋点)

订阅模块直接使用 `AnalyticsManager` 进行埋点，无需额外配置。

### 自动记录的事件

订阅模块会自动记录以下事件：

| 事件名称 | 触发时机 | 参数 |
|---------|---------|------|
| `paywall_view` | Paywall 页面展示 | `source` 或 `variant` |
| `paywall_purchase_start` | 开始购买 | `product_id` |
| `paywall_purchase_success` | 购买成功 | `product_id` |
| `paywall_purchase_cancelled` | 用户取消购买 | `product_id` |
| `paywall_purchase_failed` | 购买失败 | `product_id`, `error` |
| `paywall_restore_start` | 开始恢复购买 | - |
| `paywall_restore_success` | 恢复购买成功 | - |
| `paywall_restore_failed` | 恢复购买失败 | `error` |
| `paywall_restore_no_subscription` | 未找到订阅 | - |
| `paywall_action` | 用户交互动作 | `action`, `plan_id`, `title` |
| `paywall_option_select` | 选择订阅选项 | `plan_id`, `title` |

### 事件名称常量

可以使用 `JetPaywallEvent` 枚举访问事件名称常量：

```swift
JetPaywallEvent.view              // "paywall_view"
JetPaywallEvent.action            // "paywall_action"
JetPaywallEvent.optionSelect      // "paywall_option_select"
JetPaywallEvent.purchaseStart     // "paywall_purchase_start"
JetPaywallEvent.purchaseSuccess   // "paywall_purchase_success"
JetPaywallEvent.purchaseCancelled // "paywall_purchase_cancelled"
JetPaywallEvent.purchaseFailed    // "paywall_purchase_failed"
JetPaywallEvent.restoreStart      // "paywall_restore_start"
JetPaywallEvent.restoreSuccess    // "paywall_restore_success"
JetPaywallEvent.restoreFailed     // "paywall_restore_failed"
JetPaywallEvent.restoreNoSubscription // "paywall_restore_no_subscription"
```

### 手动记录事件

如需手动记录 Paywall 相关事件：

```swift
// 记录 Paywall 显示
AnalyticsManager.logPaywallShow(source: "settings")
AnalyticsManager.logPaywallView(variant: "trial")

// 记录购买事件
AnalyticsManager.logPurchaseStart(productId: "com.app.yearly")
AnalyticsManager.logPurchaseSuccess(productId: "com.app.yearly")
AnalyticsManager.logPurchaseCancelled(productId: "com.app.yearly")
AnalyticsManager.logPurchaseFailed(productId: "com.app.yearly", error: "Network error")

// 记录恢复购买
AnalyticsManager.logRestoreSuccess()
AnalyticsManager.logRestoreFailed(error: "No subscription found")

// 通用事件记录
AnalyticsManager.logEvent(JetPaywallEvent.action, parameters: [
    "action": "dismiss",
    "source": "header_close"
])
```

---

## 🏗 架构说明

### 数据流

1. **StoreKit** 发出交易更新。
2. **JetTransactionObserver** 捕获更新。
3. **JetEntitlementCacheManager** 将状态（是否过期、过期时间）加密存入 **Keychain**。
4. App 通过 `cachedIsPro()` 读取状态，无需联网。

### 文件概览

* **Core**:
* `JetStoreService.swift`: 封装 StoreKit 2 的 `Product` 和 `Transaction` API。
* `JetTransactionObserver.swift`: 负责后台监听 `Transaction.updates`。
* `JetIAPBootstrap.swift`: 也就是 Manager 的角色，负责胶合 Service 和 Observer。


* **Cache**:
* `JetEntitlementCache.swift`: 缓存数据模型 (Codable)。
* `JetKeychainStore.swift`: 安全存储工具类。


* **UI**:
* `JetPaywallViewModel.swift`: 处理加载产品、购买、恢复逻辑。
* `JetPaywallView.swift`: 标准 Paywall UI。
* `JetTrialPaywallView.swift`: 试用引导 UI。



---

## ⚠️ 注意事项

1. **Capability**: 确保在 Xcode 的 "Signing & Capabilities" 中添加了 **In-App Purchase**。
2. **Keychain Sharing**: 如果你在多个 App 或 Extension (Widget) 间共享订阅状态，初始化时需传入 `accessGroup` 参数：
```swift
JetIAPBootstrap(config: config, accessGroup: "group.com.yourapp.shared")

```


3. **StoreKit Testing**: 在开发阶段，请使用 Xcode 的 `.storekit` 配置文件进行本地测试。

---

## 🌍 本地化支持 (Localization)

订阅模块提供了完整的多语言支持，所有 UI 文案都可以本地化。

### 文件结构

```
Features/Subscription/
├── Resources/
│   ├── en.lproj/
│   │   └── Subscription.strings    # 英文
│   └── zh-Hans.lproj/
│       └── Subscription.strings    # 简体中文
└── Strings+Subscription.swift      # Swift 字符串扩展
```

### 使用方式

使用 `SubL` 命名空间访问本地化字符串：

```swift
import JetUI

// 标题
let title = SubL.Title.unlockPro          // "Unlock Pro" / "解锁专业版"
let trial = SubL.Title.startTrial         // "Start Your Free Trial"

// 按钮
let continueBtn = SubL.Button.continue    // "Continue" / "继续"
let restoreBtn = SubL.Button.restore      // "Restore" / "恢复"

// 订阅周期
let yearly = SubL.Period.yearly           // "Yearly" / "年度"
let months = SubL.Period.months(3)        // "3 Months" / "3 个月"

// 试用相关
let freeTrial = SubL.Trial.dayFreeTrial(7)  // "7 Day Free Trial"
let trialMsg = SubL.Trial.freeThenPrice(trialPeriod: "7 days", price: "$9.99/year")

// 价格显示
let priceTag = SubL.Price.perYear("$29.99")  // "$29.99/year"
let saveTag = SubL.Price.savePercent(50)     // "Save 50%"

// 错误信息
let error = SubL.Error.purchaseFailed        // "Purchase failed"

// 权益功能点
let benefit1 = SubL.Benefit.unlimitedAccess  // "Unlimited Access"
let benefit2 = SubL.Benefit.noAds            // "No Ads"
```

### 添加新语言

1. 在 `Resources/` 下创建新的语言目录，如 `ja.lproj/`
2. 复制 `en.lproj/Subscription.strings` 到新目录
3. 翻译所有字符串值
4. 确保 key 保持不变

### 字符串分类

| 分类 | 命名空间 | 用途 |
|-----|---------|------|
| 标题 | `SubL.Title` | Paywall 页面标题 |
| 周期 | `SubL.Period` | 订阅周期文案 |
| 试用 | `SubL.Trial` | 免费试用相关 |
| 按钮 | `SubL.Button` | 按钮文案 |
| 价格 | `SubL.Price` | 价格显示 |
| 法律 | `SubL.Legal` | 隐私政策、条款等 |
| 错误 | `SubL.Error` | 错误提示 |
| 权益 | `SubL.Benefit` | 功能点描述 |
| 状态 | `SubL.Status` | 订阅状态 |
| 无障碍 | `SubL.Accessibility` | VoiceOver 等 |

---

## 🔧 优化建议

基于代码审查，以下是订阅模块的优化建议：

### 1. 架构优化

#### 1.1 拆分 ViewModel 职责
**现状**: `JetPaywallViewModel` 同时处理产品加载、购买、恢复、埋点等多项职责。

**建议**: 考虑拆分为更细粒度的组件：
```swift
// 产品加载服务
class ProductCatalogService { }

// 购买处理器
class PurchaseProcessor { }

// 埋点代理
class PaywallAnalyticsProxy { }
```

#### 1.2 状态管理优化
**现状**: 使用多个 `@Published` 属性管理状态。

**建议**: 考虑使用状态枚举集中管理：
```swift
enum PaywallState {
    case idle
    case loading
    case ready(products: [Product])
    case purchasing(product: Product)
    case success
    case error(message: String)
}
```

### 2. 错误处理优化

#### 2.1 错误类型扩展
**建议**: 扩展 `JetStoreError` 以支持更多场景：
```swift
enum JetStoreError: Error {
    case cancelled
    case pending
    case unknown
    case noProducts
    case purchaseFailed(String)
    case networkError(underlying: Error)  // 新增
    case verificationFailed               // 新增
    case serverBindingFailed              // 新增
}
```

#### 2.2 错误恢复策略
**建议**: 为后端绑定失败添加重试机制：
```swift
func bindToBackendWithRetry(jws: String, maxRetries: Int = 3) async throws {
    var lastError: Error?
    for attempt in 1...maxRetries {
        do {
            try await accountService.bindSubscription(signedPayLoad: jws, ...)
            return
        } catch {
            lastError = error
            try await Task.sleep(nanoseconds: UInt64(attempt * 1_000_000_000))
        }
    }
    throw lastError ?? JetStoreError.unknown
}
```

### 3. UI 组件优化

#### 3.1 `JetPriceRow` 可访问性
**建议**: 添加完整的 VoiceOver 支持：
```swift
.accessibilityLabel(SubL.Accessibility.priceOption(name: title, price: price))
.accessibilityHint(isSelected ? SubL.Accessibility.planSelected(title) : "")
.accessibilityAddTraits(isSelected ? .isSelected : [])
```

#### 3.2 加载状态骨架屏
**建议**: 在产品加载时显示骨架屏而非简单的进度指示器：
```swift
struct PriceRowSkeleton: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 20)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 150, height: 14)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.2))
                .frame(width: 60, height: 20)
        }
        .padding()
        .shimmer() // 添加闪烁动画
    }
}
```

### 4. 缓存优化

#### 4.1 产品信息缓存
**建议**: 缓存产品信息以减少 StoreKit 请求：
```swift
actor ProductCache {
    private var products: [String: Product] = [:]
    private var lastFetchTime: Date?
    private let cacheValidDuration: TimeInterval = 3600 // 1小时
    
    func getProducts(ids: [String]) async throws -> [Product] {
        if let lastFetch = lastFetchTime,
           Date().timeIntervalSince(lastFetch) < cacheValidDuration,
           !products.isEmpty {
            return Array(products.values)
        }
        // 从 StoreKit 获取
        let fetched = try await Product.products(for: ids)
        // 更新缓存
        for product in fetched {
            products[product.id] = product
        }
        lastFetchTime = Date()
        return fetched
    }
}
```

### 5. 测试覆盖

#### 5.1 Mock 服务协议
**现状**: `JetStoreServiceProtocol` 支持 Mock，但未提供默认 Mock 实现。

**建议**: 提供测试用 Mock：
```swift
#if DEBUG
class MockStoreService: JetStoreServiceProtocol {
    var mockProducts: [Product] = []
    var mockIsPro = false
    var shouldFailPurchase = false
    
    func fetchProducts() async throws -> [Product] {
        return mockProducts
    }
    
    func isEntitledToPro() async -> Bool {
        return mockIsPro
    }
    
    // ... 其他方法
}
#endif
```

### 6. 性能优化

#### 6.1 减少不必要的刷新
**建议**: 在 `refreshEntitlements()` 中添加节流：
```swift
private var lastRefreshTime: Date?
private let minRefreshInterval: TimeInterval = 5

func refreshEntitlements() async {
    guard lastRefreshTime == nil || 
          Date().timeIntervalSince(lastRefreshTime!) > minRefreshInterval else {
        return
    }
    lastRefreshTime = Date()
    isPro = await storeService.isEntitledToPro()
}
```

---

## 📁 文件清单

```
Features/Subscription/
├── JetSubscriptionConfig.swift      # 配置模型
├── JetSubscriptionManager.swift     # 订阅管理器
├── JetPaywallTypes.swift            # 类型定义
├── JetStoreService.swift            # StoreKit 服务
├── Strings+Subscription.swift       # 本地化字符串
├── Subscription_README.md           # 本文档
│
├── Core/
│   ├── JetEntitlementCache.swift    # 权益缓存
│   ├── JetKeychainStore.swift       # Keychain 存储
│   └── JetTransactionObserver.swift # 交易监听
│
├── ViewModels/
│   └── JetPaywallViewModel.swift    # Paywall VM
│
├── Views/
│   ├── JetPaywall.swift             # 统一入口
│   ├── JetPaywallView.swift         # 标准 Paywall
│   ├── JetTrialPaywallView.swift    # 试用 Paywall
│   └── JetPriceRow.swift            # 价格行组件
│
└── Resources/
    ├── en.lproj/Subscription.strings
    └── zh-Hans.lproj/Subscription.strings
```

---

**文档版本**: 2.0  
**最后更新**: 2026-02-21  
**维护者**: JetUI Team
