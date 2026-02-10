# JetSubscription Library

**JetSubscription** 是一个基于 **StoreKit 2** 的轻量级、模块化 iOS 订阅管理库。它提供了从底层收据验证、本地安全缓存到现成的高颜值 Paywall UI 的一站式解决方案。

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

如果你需要对接 Firebase、Mixpanel 或自家后端，只需实现 `JetPaywallAnalytics` 协议：

```swift
class MyAnalyticsHandler: JetPaywallAnalytics {
    func logEvent(_ name: String, parameters: [String : Any]) {
        // 发送给你的统计 SDK
        Analytics.logEvent(name, parameters: parameters)
        print("📊 [Paywall Event]: \(name) - \(parameters)")
    }
}

// 注入到 ViewModel 或 Paywall View 中
let viewModel = JetPaywallViewModel(
    config: config, 
    analytics: MyAnalyticsHandler()
)

```

**支持的事件：**

* `paywall_view`
* `paywall_purchase_start`
* `paywall_purchase_success`
* `paywall_purchase_failed`
* `paywall_restore_success`
* ...

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