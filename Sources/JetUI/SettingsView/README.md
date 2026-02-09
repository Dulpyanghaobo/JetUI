# JetUI Settings Module

一个可配置的通用设置页面组件，支持多种 UI 风格。

## 快速开始（推荐）

使用简化 API，只需提供必要的 URL 和配置：

```swift
import JetUI

// 方式一：使用别名（最简洁）
.sheet(isPresented: $showSettings) {
    JetSettings(config: JetConfig(
        appName: "TimeProof",
        appStoreURL: "https://apps.apple.com/app/id123456789",
        shareText: "Check out TimeProof - Timestamp your photos!",
        privacyPolicyURL: "https://example.com/privacy",
        feedbackEmail: "support@example.com",
        style: .dark  // 可选：.dark, .lightCard, .standard
    ))
}

// 方式二：使用完整类型名
.sheet(isPresented: $showSettings) {
    JetSimpleSettingsView(config: JetAppConfig(
        appName: "TimeProof",
        appStoreURL: "https://apps.apple.com/app/id123456789",
        shareText: "Check out TimeProof!",
        termsOfUseURL: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/",
        privacyPolicyURL: "https://example.com/privacy",
        feedbackEmail: "support@example.com",
        feedbackSubject: "TimeProof Feedback",
        style: .dark
    ))
}
```

## 支持的风格

| 风格 | 枚举值 | 适用场景 |
|------|--------|---------|
| 深色主题 | `.dark` | TimeProof, WatermarkCamera 等深色 App |
| 深色+会员卡 | `.darkWithMembership` | 带订阅功能的深色 App |
| 浅色卡片 | `.lightCard` | AlarmApp 等现代浅色 App |
| 标准系统 | `.standard` | DocumentScan 等系统风格 App |

## 内置功能

使用简化 API 时，以下功能已内置，无需额外配置：

- ✅ **恢复购买** - 使用 StoreKit 2 的 `AppStore.sync()`
- ✅ **分享应用** - 系统分享面板
- ✅ **评价应用** - `AppStore.requestReview()`
- ✅ **服务条款** - 打开 URL
- ✅ **隐私政策** - 打开 URL
- ✅ **反馈邮件** - 自动附带设备和版本信息
- ✅ **应用推荐** - `JetRecommendationsView`（底部）
- ✅ **成功/失败弹窗** - 恢复购买结果提示

## JetAppConfig 参数说明

```swift
JetAppConfig(
    appName: String,           // App 名称（用于邮件等）
    appStoreURL: String,       // App Store 链接
    shareText: String,         // 分享文案
    termsOfUseURL: String,     // 服务条款 URL（默认 Apple 标准条款）
    privacyPolicyURL: String,  // 隐私政策 URL
    feedbackEmail: String,     // 反馈邮箱
    feedbackSubject: String?,  // 邮件主题（默认 "{appName} Feedback"）
    style: JetSettingsStyle    // 风格（默认 .dark）
)
```

---

## 高级用法（完全自定义）

如果需要完全自定义设置页面，可以使用高级 API：

```swift
import JetUI

JetSettingsView(
    configuration: JetSettingsConfiguration.timeProofStyle(
        sections: [
            JetSettingSection(
                header: "Settings",
                items: [
                    JetSettingItem(icon: .system("creditcard"), title: "Restore") { },
                    JetSettingItem(icon: .image("custom_icon"), title: "Custom") { }
                ]
            )
        ],
        customBottomView: AnyView(MyCustomView())
    )
)
```

## API 参考

### 简化 API（推荐）

| 类型 | 别名 | 描述 |
|-----|------|------|
| `JetSimpleSettingsView` | `JetSettings` | 简化版设置页面 |
| `JetAppConfig` | `JetConfig` | 应用配置 |
| `JetSettingsStyle` | - | 风格枚举 |

### 高级 API

| 类型 | 描述 |
|-----|------|
| `JetSettingsView` | 可配置设置页面 |
| `JetSettingsConfiguration` | 完整配置 |
| `JetSettingSection` | 分组数据 |
| `JetSettingItem` | 设置项数据 |
| `JetSettingIcon` | 图标类型 |
| `JetSettingsActions` | 工具方法 |

### 工具类

```swift
// 打开 URL
JetSettingsActions.openURL("https://...")

// 发送反馈邮件
JetSettingsActions.sendFeedbackEmail(
    to: "support@example.com",
    subject: "Feedback",
    appName: "MyApp"
)

// 分享应用
JetSettingsActions.shareApp(
    text: "Check out this app!",
    appStoreURL: "https://apps.apple.com/..."
)

// 请求评价（需要 @MainActor）
JetSettingsActions.requestReview()
```

## 文件结构

```
Sources/JetUI/Settings/
├── JetAppConfig.swift          // 简化配置模型
├── JetSimpleSettingsView.swift // 简化版设置页面（推荐）
├── JetSettingsConfiguration.swift  // 高级配置协议
├── JetSettingsView.swift       // 高级设置页面
├── JetSettingItemRow.swift     // 设置行组件
├── JetMembershipCardView.swift // 会员卡片组件
├── JetSettingsPresets.swift    // 预设配置
├── JetSettingsActions.swift    // 工具类
└── README.md                   // 使用文档