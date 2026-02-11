# JetTheme 使用与迁移指南

## 1. 系统概述

`JetTheme` 是一个基于协议（Protocol-Oriented）的主题管理系统。它通过依赖注入的方式管理颜色、字体和布局间距，使整个 App 能够轻松支持多主题（如暗黑模式、品牌换肤），并强制执行统一的设计规范。

**核心架构：**

* **Protocols (`JetThemeProtocols.swift`)**: 定义了设计规范的接口（"我们需要什么颜色/字体"）。
* **Implementation (`DefaultTheme.swift`)**: 具体的样式值（"实际是红色/Quicksand字体"）。
* **Injection (`JetUI`)**: 全局单例，负责持有当前的主题实例。
* **Accessors (`AppTheme`, `AppColor`)**: 供 View 层调用的入口。

---

## 2. 快速开始 (Setup)

在 App 启动时（例如 `App.swift` 或 `AppDelegate`），你需要配置当前使用的主题。如果不配置，系统默认使用 `DefaultTheme`（即旧版样式）。

```swift
import SwiftUI

@main
struct MyApp: App {
    
    init() {
        // 1. 初始化主题
        // 你可以在这里根据用户设置或系统环境切换不同的主题类
        JetUI.theme = DefaultTheme() 
        
        // 示例：如果未来有暗黑主题
        // JetUI.theme = DarkTheme()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

```

---

## 3. 使用指南 (Usage)

### 3.1 颜色 (Colors)

**❌ 旧方式 (Hardcoded):**

```swift
Color(hex: 0x2786D5)
// 或
Color.blue

```

**✅ 新方式 (Semantic):**
推荐使用 `AppTheme.colors` 访问语义化颜色。

```swift
Text("Hello World")
    .foregroundColor(AppTheme.colors.textPrimary) // 主要文字色
    .background(AppTheme.colors.brandPrimary)     // 品牌色

```

> **注意**：为了兼容旧代码，`AppColor.themeColor` 依然可用，它们现在是代理属性，底层也会读取当前主题配置。

### 3.2 字体 (Typography)

**❌ 旧方式:**

```swift
Font.system(size: 20, weight: .bold)

```

**✅ 新方式:**
使用 `AppTheme.fonts` 访问预定义的字体层级。

```swift
VStack {
    Text("Title").font(AppTheme.fonts.displayL)
    Text("Subtitle").font(AppTheme.fonts.headingM)
    Text("Body text").font(AppTheme.fonts.bodyM)
}

```

### 3.3 布局与间距 (Layout & Spacing) ✨ *New*

这是本次重构的核心提升。不要再手写数字（如 `16`, `8`, `24`），请使用 `JetLayoutExtensions` 提供的修饰符。

**基本映射表：**

* `xs` = 4pt
* `s`  = 8pt
* `m`  = 16pt (标准间距)
* `l`  = 24pt
* `xl` = 32pt

#### Padding (内边距)

```swift
// ❌ Avoid
.padding(16)
.padding(.horizontal, 24)

// ✅ Use
.jetPadding(\.m)              // 四周 16pt
.jetPadding(.horizontal, \.l) // 水平 24pt

```

#### Corner Radius (圆角)

```swift
// ❌ Avoid
.cornerRadius(8)

// ✅ Use
.jetCornerRadius(\.medium) // 8pt
.jetCornerRadius(\.pill)   // 胶囊圆角

```

#### Frame (尺寸)

```swift
// 使用间距系统定义宽高
Image("icon")
    .jetFrame(width: \.xl, height: \.xl) // 32x32

```

---

## 4. 全局替换迁移策略 (Migration Strategy)

为了安全地将整个 Project 进行全局替换，建议按照以下步骤进行：

### 第一阶段：兼容性验证 (Proxy Pattern)

目前代码库中已有的 `AppColor` 和 `AppFont` 已经被重构为**代理模式**。

* **无需修改业务代码**，直接运行项目。
* 检查 `DefaultTheme.swift` 中的值是否与原来的视觉一致。
* **目的**：确保引入新架构后，现有界面没有崩溃或明显的视觉错误。

### 第二阶段：颜色与字体替换 (Search & Replace)

利用 IDE 的全局搜索替换功能，逐步淘汰硬编码值。

1. **搜索 `Color(hex:**`:
* 将分散在各处的 Hex 颜色替换为 `AppTheme.colors.xxx` 中最接近的语义色。
* 例如：`0x2786D5` -> `AppTheme.colors.brandPrimary`。


2. **搜索 `Font.custom` 或 `Font.system**`:
* 将其替换为 `AppTheme.fonts.xxx`。



### 第三阶段：布局重构 (Layout Refactoring) **(重点)**

这是工作量最大的部分。需要逐个 View 文件进行优化。

**步骤：**

1. 找到所有的 `.padding(...)`。
* 如果是标准值（4, 8, 16, 24），替换为 `.jetPadding(...)`。
* 如果是特殊值（比如 13.5），暂时保留或定义新的 spacing token。


2. 找到所有的 `.cornerRadius(...)`。
* 替换为 `.jetCornerRadius(...)`。


3. 检查 `HStack` 和 `VStack` 的 `spacing` 参数。
* **旧**: `VStack(spacing: 16)`
* **新**: `VStack(spacing: \.m)` (利用 `JetLayoutExtensions` 中的扩展初始化方法)。



### 第四阶段：清理 (Cleanup)

当所有页面都迁移到 `AppTheme` 后：

1. 可以将 `AppColor` 和 `AppFont` 标记为 `@available(*, deprecated)`，提醒团队不再使用。
2. 最终删除 `AppColor` 和 `AppFont` 文件，只保留 `AppTheme`。

---

## 5. 自定义主题示例 (Creating a Theme)

如果未来需要做“暗黑模式”或“春节版”，只需新建一个 struct 实现协议：

```swift
struct DarkTheme: JetThemeConfig {
    var colors: JetColorPalette { DarkColors() }
    var fonts: JetTypography { DefaultTypography() } // 字体通常不变
    var layout: JetLayoutConfig { DefaultLayoutConfig() } // 布局通常不变
}

struct DarkColors: JetColorPalette {
    // 重写必要的颜色
    var brandPrimary: Color { Color(hex: 0x4A90E2) } // 更亮的蓝色
    var backgroundPrimary: Color { Color.black }
    var textPrimary: Color { Color.white }
    
    // ...实现协议中的其他属性
}

```

然后切换：

```swift
JetUI.theme = DarkTheme()

```

---

## 6. 常用速查表 (Cheat Sheet)

| 类别 | 属性名 | 对应值 (Default) | 场景 |
| --- | --- | --- | --- |
| **Spacing** | `xs` | 4 | 极小间隙 |
|  | `s` | 8 | 元素内部间距 |
|  | `m` | 16 | **标准** 模块间距 |
|  | `l` | 24 | 区块间距 |
|  | `xl` | 32 | 大留白 |
| **Radius** | `small` | 4 | 标签、小按钮 |
|  | `medium` | 8 | **标准** 卡片圆角 |
|  | `large` | 16 | 弹窗、大容器 |
|  | `pill` | 999 | 胶囊按钮 |
| **Font** | `displayXXL` | 70/Bold | 巨型数字/Hero |
|  | `headingM` | 24/Bold | 页面标题 |
|  | `bodyM` | 16/Medium | **标准** 正文 |
|  | `caption` | 12/Medium | 辅助说明 |