# JetUI Migration Guide

## 订阅模块迁移 (Subscription Module Migration)

### 迁移概述

TimeProof 的订阅组件已下沉到 JetUI，形成通用的订阅基础设施。

### 已迁移的组件

| TimeProof 原文件 | JetUI 新位置 | 说明 |
|-----------------|--------------|------|
| `KeychainStore.swift` | `Core/JetKeychainStore.swift` | Keychain 安全存储工具 |
| `EntitlementCache.swift` | `Core/JetEntitlementCache.swift` | 订阅权益缓存模型 |
| `TransactionObserver.swift` | `Core/JetTransactionObserver.swift` | StoreKit 交易观察器 |
| `SubscriptionConfig.swift` | `JetSubscriptionConfig.swift` | 订阅配置（已存在，增强） |
| `StoreService.swift` | `JetStoreService.swift` | StoreKit 服务（已存在，增强） |
| `PriceRow.swift` | `Views/JetPriceRow.swift` | 价格选项行组件（已存在） |
| `PaywallViewModel.swift` | `ViewModels/JetPaywallViewModel.swift` | Paywall 视图模型（已存在，增强） |
| `TrialPaywallView.swift` | `Views/JetTrialPaywallView.swift` | 试用版付费墙视图 |

### 保留在 TimeProof 的文件

| 文件 | 说明 |
|-----|------|
| `PaywallView.swift` | App 特定的 UI 定制，使用本地化字符串 |
| `TrialPaywallView.swift` | App 特定的试用 UI，引用本地资源 |
| `IAPBootstrap.swift` | App 启动配置，已重构为使用 JetUI 组件 |

### 使用方式

#### 1. 配置 IAP (在 App 启动时)

```swift
import JetUI

// TimeProof 已有的 IAPBootstrap 会自动使用 JetUI 组件
IAPBootstrap.start()
```

#### 2. 检查 Pro 状态

```swift
// 快速读取缓存
let isPro = IAPBootstrap.cachedIsPro()

// 或刷新后获取
let isPro = await IAPBootstrap.refreshEntitlementCache()
```

#### 3. 使用 JetUI 的 Trial Paywall

```swift
import JetUI

JetTrialPaywallView(
    config: JetTrialPaywallConfig(
        backgroundColor: AppColor.subscripBackColor,
        accentColor: AppColor.themeColor,
        trialTitle: "How Free Trial Works",
        trialSteps: [
            .init(iconName: "paywell_icon_weekly_1", title: "Today - Full Access"),
            .init(iconName: "paywell_icon_weekly_2", title: "Day 5 - Reminder"),
            .init(iconName: "paywell_icon_weekly_3", title: "Day 7 - Subscription Starts")
        ],
        benefits: [
            .init(iconName: "subscript_lifetime_1", title: "Unlimited Timestamps"),
            .init(iconName: "subscript_lifetime_2", title: "Professional Filters"),
            .init(iconName: "subscript_lifetime_3", title: "Premium Features"),
            .init(iconName: "subscript_lifetime_4", title: "No Ads")
        ]
    ),
    subscriptionConfig: IAPBootstrap.config,
    onSuccess: { /* 购买成功 */ }
)
```

#### 4. 类型别名兼容

为了兼容旧代码，IAPBootstrap 提供了类型别名：

```swift
typealias SubscriptionConfig = JetSubscriptionConfig
typealias StoreService = JetStoreServiceProtocol
typealias StoreKitStore = JetStoreService
typealias StoreError = JetStoreError
typealias EntitlementCache = JetEntitlementCache
typealias KeychainStore = JetKeychainStore
typealias TransactionObserver = JetTransactionObserver
```

### JetUI 新增的组件

#### JetKeychainStore

Keychain 安全存储工具：

```swift
// 保存
try JetKeychainStore.save(value, for: "key", accessGroup: "group")

// 读取
let value = try JetKeychainStore.load(MyType.self, for: "key")

// 删除
JetKeychainStore.delete(for: "key")
```

#### JetEntitlementCache

订阅权益缓存：

```swift
// 读取缓存
let cache = JetEntitlementCacheManager.load()
let isPro = cache?.isValid ?? false

// 保存缓存
JetEntitlementCacheManager.save(JetEntitlementCache(
    isPro: true,
    expiration: Date().addingTimeInterval(86400),
    productId: "com.app.pro"
))

// 清除缓存
JetEntitlementCacheManager.clear()
```

#### JetTransactionObserver

交易观察器：

```swift
let observer = JetTransactionObserver(
    storeService: storeService,
    config: config,
    accessGroup: accessGroup
)

// 开始监听
observer.startObserving()

// 刷新权益
let isPro = await observer.refreshEntitlementCache()

// 停止监听
observer.stopObserving()
```

#### JetIAPBootstrap

IAP 启动助手：

```swift
let bootstrap = JetIAPBootstrap(config: config, accessGroup: accessGroup)

// 启动
bootstrap.start()

// 检查状态
let isPro = bootstrap.isPro()

// 刷新
let isPro = await bootstrap.refreshEntitlementCache()
```

#### JetTrialPaywallView

试用版付费墙：

```swift
JetTrialPaywallView(
    config: JetTrialPaywallConfig(
        backgroundColor: .purple,
        accentColor: .orange,
        trialTitle: "Free Trial",
        trialSteps: [...],
        benefits: [...]
    ),
    subscriptionConfig: subscriptionConfig,
    analytics: myAnalytics,
    onSuccess: { }
)
```

### 注意事项

1. **PaywallView 保留在 TimeProof**: 因为它包含大量 App 特定的 UI 定制和本地化字符串引用
2. **类型别名**: 使用类型别名保持向后兼容
3. **权益变更通知**: 监听 `JetTransactionObserver.entitlementChangedNotification` 获取权益变更
4. **Keychain Access Group**: 确保配置正确的 access group 以支持跨 App 共享

---


## 概述

JetUI 是一个可复用的 iOS 组件库，从 TimeProof 项目中提取公共组件供多项目使用。

## 架构设计原则

### 1. 分层架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         Host App (TimeProof, PetPal 等)         │
├─────────────────────────────────────────────────────────────────┤
│   App-Specific Features                                          │
│   • 自定义 UI 设计                                               │
│   • 业务特定逻辑                                                 │
│   • 本地化字符串                                                 │
├─────────────────────────────────────────────────────────────────┤
│                            JetUI                                 │
│   ┌─────────────────┬─────────────────┬─────────────────────┐  │
│   │   Components    │    Features     │      Network        │  │
│   │   • Toast       │    • Paywall    │   • NetworkCore     │  │
│   │   • Alert       │    • Onboarding │   • AccountService  │  │
│   │   • Glass       │    • Settings   │   • AuthSession     │  │
│   │   • CacheImage  │                 │                     │  │
│   ├─────────────────┼─────────────────┼─────────────────────┤  │
│   │     Core        │     Theme       │     Firebase        │  │
│   │   • CacheManager│   • AppColor    │   • StorageManager  │  │
│   │   • CSLogger    │   • AppFont     │                     │  │
│   │   • Helpers     │                 │                     │  │
│   └─────────────────┴─────────────────┴─────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 2. 依赖注入与适配器模式

JetUI 使用协议定义接口，Host App 实现具体逻辑：

```swift
// JetUI 定义协议
public protocol AccountServiceProtocol {
    func bindSubscription(signedPayLoad: String, ...) async throws
}

// JetUI 提供默认实现
public final class DefaultAccountService: AccountServiceProtocol { ... }

// Host App 可以注入自定义实现
let storeService = JetStoreService(
    config: config,
    accountService: MyCustomAccountService()  // 自定义实现
)
```

---

## 模块说明

### Components (UI 组件)

| 组件 | 文件 | 说明 |
|-----|------|------|
| Toast | `JetToastView.swift` | 轻量级提示弹窗 |
| Alert | `JetCustomAlertView.swift`, `JetTextFieldAlert.swift` | 自定义警告框 |
| Glass | `JetGlassBackground.swift` | 毛玻璃背景效果 |
| Switch | `JetCustomSwitch.swift` | 自定义开关 |
| Image | `JetCacheAsyncImage.swift` | 带缓存的异步图片加载 |
| Lottie | `JetLottieView.swift` | Lottie 动画封装 |

**使用示例：**
```swift
import JetUI

// Toast
JetToastView.show(message: "保存成功", style: .success)

// 缓存图片
JetCacheAsyncImage(url: imageURL)
```

### Core (核心工具)

| 工具 | 文件 | 说明 |
|-----|------|------|
| CacheManager | `CacheManager.swift` | 通用数据缓存 |
| CSLogger | `CSLogger.swift` | 分类日志系统 |
| CircuitBreaker | `CircuitBreaker.swift` | 熔断器模式 |
| MemoryMonitor | `MemoryMonitor.swift` | 内存监控 |
| StateHelpers | `StateHelpers.swift` | @PublishedGuard 等 |
| DateFormatter | `JetDateFormatter.swift` | 日期格式化工具 |
| AssetSaver | `JetAssetSaver.swift` | 相册保存工具 |

### Theme (主题系统)

```swift
// 颜色
AppColor.themeColor      // 主题色
AppColor.background      // 背景色
AppColor.cardBackground  // 卡片背景

// 字体
AppFont.headingL         // 大标题
AppFont.bodyM            // 正文
AppFont.caption          // 注释
```

### Network (网络层)

**核心类：**
- `NetworkCore` - 基于 Moya 的网络请求
- `AccountService` - 账户相关 API
- `AuthSession` - Token 管理

```swift
// 发起请求
let result = try await NetworkCore.shared.api(
    MyTarget.someEndpoint,
    ResponseModel.self
)

// 账户操作
try await DefaultAccountService.shared.bindSubscription(
    signedPayLoad: jws,
    storeKitType: 2,
    usageType: 1
)
```

### Features/Subscription (订阅模块)

JetUI 提供完整的订阅功能，包括：

**组件列表：**
- `JetSubscriptionConfig` - 订阅配置
- `JetStoreService` - StoreKit 2 服务
- `JetSubscriptionManager` - 订阅状态管理
- `JetPaywallViewModel` - Paywall 业务逻辑
- `JetPaywallView` - 通用 Paywall UI
- `JetPriceRow` - 价格行组件

**使用方式 A：使用 JetUI 完整 Paywall**
```swift
// 适合新项目或需要标准 UI 的场景
let config = JetSubscriptionConfig(
    productIds: ["yearly", "weekly"],
    proProductIds: ["yearly"]
)

JetPaywallView(
    config: config,
    headerImage: Image("paywall_bg"),
    title: "GPS CAM PRO",
    benefits: ["无限水印", "专业滤镜"],
    onSuccess: { dismiss() },
    onDismiss: { dismiss() }
)
```

**使用方式 B：仅使用业务逻辑（自定义 UI）**
```swift
// 适合有定制 UI 需求的项目（如 TimeProof）
@StateObject private var vm = JetPaywallViewModel(config: config)

// 在自定义 View 中使用 vm 的状态
VStack {
    ForEach(vm.plans) { plan in
        // 自定义 UI
    }
}
.task { await vm.load() }
```

**使用方式 C：仅使用 StoreService**
```swift
// 最小化使用，完全自定义
let store = JetStoreService(config: config)
let products = try await store.fetchProducts()
let (tx, jws) = try await store.purchase(product)
// JetStoreService 内部自动调用 bindSubscription
```

### Features/Onboarding (引导页)

```swift
JetOnboardingView(
    pages: [...],
    onComplete: { /* 进入主页 */ }
)
```

### Features/Settings (设置页)

```swift
JetSimpleSettingsView(config: settingsConfig)
```

### Firebase

```swift
// 上传文件
try await JetStorageManager.shared.uploadFile(
    data: imageData,
    path: "users/\(userId)/avatar.jpg"
)
```

---

## TimeProof 项目特殊说明

TimeProof 项目有以下特殊处理：

### 1. 订阅模块

TimeProof 保留自己的订阅实现，原因：
- 自定义 Paywall UI 设计（品牌图片、动画效果）
- 特定的业务逻辑（Analytics 埋点、成长系统集成）
- 已有稳定运行的代码

**文件保留：**
```
TimeProof/Feature/Subscription/
├── PaywallView.swift          # 自定义 UI
├── PaywallViewModel.swift     # 业务逻辑
├── StoreService.swift         # StoreKit 服务
├── SubscriptionConfig.swift   # 配置
└── ...
```

### 2. 网络层

TimeProof 使用 JetUI 的 `NetworkCore` 和 `DefaultAccountService`：

```swift
// TimeProof 中的使用
import JetUI

// 后端绑定订阅（PaywallViewModel.swift）
try await DefaultAccountService.shared.bindSubscription(
    signedPayLoad: jws,
    storeKitType: 2,
    usageType: 1
)
```

### 3. 适配器

TimeProof 在 `JetUIAdapters.swift` 中定义了一些适配器：

```swift
// 使用 JetUI 组件时的适配
JetCacheAsyncImage(url: url)
    .frame(width: 100, height: 100)
```

---

## 添加新组件指南

### 1. 确定放置位置

- **通用 UI 组件** → `Components/`
- **业务功能模块** → `Features/`
- **工具类** → `Core/`
- **网络相关** → `Network/`

### 2. 命名规范

- 类型名以 `Jet` 开头：`JetToastView`, `JetCacheManager`
- 文件名与类型名一致：`JetToastView.swift`

### 3. 导出公开 API

在 `JetUI.swift` 中添加 re-export：

```swift
// JetUI.swift
@_exported import struct JetUI.JetToastView
```

### 4. 更新文档

在本文件中添加组件说明。

---

## 依赖说明

JetUI Package.swift 依赖：

```swift
dependencies: [
    .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0"),
    .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0"),
    .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.3.0")
]
```

---

## 版本历史

| 版本 | 日期 | 变更 |
|-----|------|------|
| 1.0 | 2026-02-10 | 初始版本，从 TimeProof 提取组件 |
| 1.1 | 2026-02-10 | 添加订阅模块完整实现，JetStoreService 集成后端绑定 |