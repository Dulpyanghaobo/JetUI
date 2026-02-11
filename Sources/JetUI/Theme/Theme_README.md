这份 Markdown Guide 旨在指导你如何将 `JetUI` 从一个“硬编码样式的组件库”重构为一个“通用的、可配置的设计系统”。

---

# 🚀 JetUI Theme Refactoring Plan

> **Objective**: 解耦样式与逻辑，通过依赖注入（Dependency Injection）实现多 App 复用，建立完整的设计系统规范。

## Phase 1: 核心架构重构 (Core Architecture)

目前的 `AppColor` 和 `AppFont` 存储了具体的值。重构的第一步是建立**协议（Protocol）**，让 `JetUI` 只知道“这里需要一个主色”，而不知道“主色具体是什么”。

### 1.1 定义抽象协议 (Protocols)

在 `JetUI/Theme` 目录下新建 `JetThemeProtocols.swift`：

```swift
import SwiftUI

// MARK: - 1. 颜色语义协议
public protocol JetColorPalette {
    /// 品牌色 (Brand)
    var brandPrimary: Color { get }
    var brandSecondary: Color { get }
    
    /// 背景色 (Background)
    var backgroundPrimary: Color { get }   // 对应之前的 primaryBackground
    var backgroundSecondary: Color { get } // 对应之前的 subscripBackColor
    var backgroundTertiary: Color { get }  // 卡片或弹窗背景
    
    /// 文本色 (Text)
    var textPrimary: Color { get }   // 主要文字
    var textSecondary: Color { get } // 次要文字
    var textDisabled: Color { get }  // 不可用文字
    
    /// 功能色 (Semantic)
    var success: Color { get }
    var warning: Color { get }
    var error: Color { get }
}

// MARK: - 2. 字体语义协议
public protocol JetTypography {
    // Display
    var displayXL: Font { get }
    var displayL: Font { get }
    
    // Heading
    var headingM: Font { get }
    var headingS: Font { get }
    
    // Body
    var bodyL: Font { get }
    var bodyM: Font { get }
    var bodyS: Font { get }
    
    // Utility
    var caption: Font { get }
    var footnote: Font { get }
}

// MARK: - 3. 主题配置容器
public protocol JetThemeConfig {
    var colors: JetColorPalette { get }
    var fonts: JetTypography { get }
    // 下面会提到扩展内容
    var layout: JetLayoutConfig { get } 
}

```

### 1.2 建立配置入口 (Configuration Entry)

修改 `JetUI.swift`，增加主题注入点。建议提供一个默认的兜底主题，防止外部忘记配置导致 Crash。

```swift
// JetUI.swift

public class JetUI {
    // ... version, logging 等现有代码 ...

    // 内部持有的当前主题
    public private(set) static var theme: JetThemeConfig = DefaultJetTheme()

    /// 外部 App 调用此方法注入自定义主题
    public static func configureTheme(_ config: JetThemeConfig) {
        self.theme = config
    }
}

```

---

## Phase 2: 代码改造 (Refactoring)

将原本存储**值**的类，改为**代理（Proxy）**类，去读取配置。

### 2.1 改造 AppColor

修改 `AppColor.swift`。不要删除这个文件，因为你的组件库里大量使用了它。我们保留它作为访问入口，但把实现改成动态获取。

```swift
// AppColor.swift

public enum AppColor {
    // 将 static let 改为 static var (Computed Properties)
    
    // Brand
    public static var themeColor: Color { JetUI.theme.colors.brandPrimary }
    
    // Background
    public static var primaryBackground: Color { JetUI.theme.colors.backgroundPrimary }
    public static var subscripBackColor: Color { JetUI.theme.colors.backgroundSecondary }
    
    // Semantic
    public static var success: Color { JetUI.theme.colors.success }
    public static var warning: Color { JetUI.theme.colors.warning }
    public static var error: Color { JetUI.theme.colors.error }
    
    // Gray scale 建议映射到语义颜色，或者在协议里保留 raw palette
    public static var gray900: Color { JetUI.theme.colors.textPrimary }
}

```

### 2.2 改造 AppFont

同理修改 `AppFont.swift`：

```swift
// AppFont.swift

public enum AppFont {
    public static var displayXL: Font { JetUI.theme.fonts.displayXL }
    public static var headingM: Font { JetUI.theme.fonts.headingM }
    public static var bodyM: Font { JetUI.theme.fonts.bodyM }
    // ... 其他字体
}

```

---

## Phase 3: 扩展设计系统 (What's Missing?)

除了颜色和字体，一个成熟的 UI 库还需要以下三个维度的统一。建议新建 `JetLayoutConfig.swift`。

### 3.1 间距系统 (Spacing)

避免在代码里写死 `padding(20)`。不同 App 的疏密程度不同。

```swift
public protocol JetSpacing {
    var xs: CGFloat { get } // e.g., 4
    var s: CGFloat  { get } // e.g., 8
    var m: CGFloat  { get } // e.g., 16 (标准间距)
    var l: CGFloat  { get } // e.g., 24
    var xl: CGFloat { get } // e.g., 32
    var xxl: CGFloat { get } // e.g., 48
}

```

### 3.2 圆角系统 (Radius)

有的 App 是直角风格，有的是圆润风格。

```swift
public protocol JetRadius {
    var small: CGFloat { get }  // e.g., 4
    var medium: CGFloat { get } // e.g., 8 (卡片)
    var large: CGFloat { get }  // e.g., 16 (弹窗)
    var pill: CGFloat { get }   // e.g., 999 (胶囊按钮)
}

```

### 3.3 图标系统 (Iconography)

虽然 SF Symbols 是通用的，但不同 App 可能对同一个概念使用不同的图标（例如：设置是用 `gear` 还是 `gearshape`）。

```swift
public protocol JetIcons {
    var backArrow: Image { get }
    var close: Image { get }
    var checkmark: Image { get }
    var chevronRight: Image { get }
}

```

### 3.4 整合到 Layout Config

更新 `JetThemeProtocols.swift`：

```swift
public protocol JetLayoutConfig {
    var spacing: JetSpacing { get }
    var radius: JetRadius { get }
    var icons: JetIcons { get }
}

// 更新主配置协议
public protocol JetThemeConfig {
    var colors: JetColorPalette { get }
    var fonts: JetTypography { get }
    var layout: JetLayoutConfig { get } // 新增
}

```

---

## Phase 4: 外部使用指南 (Usage Example)

外部 App (`MyApp`) 接入 `JetUI` 的步骤：

### Step 1: 实现配置类

在 `MyApp` 中创建 `MyAppTheme.swift`：

```swift
struct MyAppColors: JetColorPalette {
    var brandPrimary: Color = Color("MyBlue") // 读取 App 里的 Assets
    var backgroundPrimary: Color = .white
    // ... 实现其余属性
}

struct MyAppFonts: JetTypography {
    var displayXL: Font = .custom("Poppins-Bold", size: 34)
    // ... 实现其余属性
}

struct MyAppLayout: JetLayoutConfig {
    struct Spacing: JetSpacing {
        let m: CGFloat = 20 // 这个 App 比较宽松
        // ...
    }
    // ...
    let spacing = Spacing()
    // ...
}

struct MyAppTheme: JetThemeConfig {
    let colors = MyAppColors()
    let fonts = MyAppFonts()
    let layout = MyAppLayout()
}

```

### Step 2: 注入配置

在 App 启动时（`App.swift` 或 `AppDelegate`）：

```swift
@main
struct MyApp: App {
    init() {
        // 关键步骤：注入主题
        JetUI.configureTheme(MyAppTheme())
        
        // 其他配置
        JetUI.configureLogger(subsystem: "com.my.app")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

```

---

## Summary Checklist (执行清单)

1. [ ] **Create Protocols**: 在 `Theme` 文件夹下新建 `JetThemeProtocols.swift`，定义 Color, Font, Spacing, Radius 协议。
2. [ ] **Update JetUI**: 在 `JetUI.swift` 中添加 `theme` 变量和 `configureTheme` 方法。
3. [ ] **Create Defaults**: 创建一个 `DefaultTheme.swift`，包含目前硬编码的值作为默认值（保证旧代码不报错）。
4. [ ] **Refactor AppColor**: 修改 `AppColor.swift`，将 `let` 改为 `var` 并指向 `JetUI.theme.colors`。
5. [ ] **Refactor AppFont**: 修改 `AppFont.swift`，指向 `JetUI.theme.fonts`。
6. [ ] **Refactor Components**: 搜索代码中的 `cornerRadius(8)` 或 `padding(16)`，替换为 `JetUI.theme.layout.radius.medium` 等。