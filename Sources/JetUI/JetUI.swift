//
//  JetUI.swift
//  JetUI
//
//  JetUI 是一个 iOS UI 组件库，提供：
//  - 主题系统（AppFont, AppColor）
//  - 日志系统（CSLogger）
//  - 网络层（NetworkCore, AuthTarget, AuthSession, AccountTarget, AccountService）
//  - 认证模型（LoginResult, UserInfo, SubscriptionStatus）
//  - 分析系统（AnalyticsManager）
//

import Foundation

// MARK: - Version

public enum JetUI {
    /// 库版本号
    public static let version = "1.1.0"
    
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
    /// - Parameter provider: 分析后端提供者
    public static func configureAnalytics(_ provider: AnalyticsProvider) {
        AnalyticsManager.provider = provider
    }
}

// MARK: - Module Documentation

/*
 JetUI 模块结构：
 
 📁 Theme/
    - AppFont.swift      : 字体定义
    - AppColor.swift     : 颜色定义
 
 📁 Core/
    - CSLogger.swift     : 统一日志系统
 
 📁 Network/
    - NetworkCore.swift  : Moya 网络核心
    - NetworkError.swift : 错误类型
    - APIResponse.swift  : 响应模型
    - AuthModels.swift   : 认证数据模型
    - AuthTarget.swift   : 认证 API 端点
    - AuthSession.swift  : Token 管理
    - AccountTarget.swift: 账户/订阅 API 端点（公共模块）
    - AccountService.swift: 账户/订阅 Service 层
 
 📁 Analytics/
    - AnalyticsManager.swift : 分析系统（协议抽象）
 
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
 
 // 4. 账户 API 请求
 let deviceInfo = DeviceInfo(
     deviceId: "xxx",
     deviceType: "iPhone",
     appVersion: "1.0.0",
     platform: "iOS"
 )
 let result = try await DefaultAccountService.shared.loginGuest(
     deviceId: "xxx",
     osVersion: "17.0",
     fcmToken: nil,
     source: "app",
     deviceInfo: deviceInfo
 )
 
 // 5. 获取用户信息
 let userInfo = try await DefaultAccountService.shared.getUserInfo()
 
 // 6. 获取订阅状态
 let status = try await DefaultAccountService.shared.getSubscriptionStatus()
 ```
 
 账户 API 端点 (AccountTarget):
 - loginGuest: 游客登录
 - appleBind: Apple 绑定登录
 - userInfo: 获取用户信息
 - subscriptionStatus: 获取订阅状态
 - bindSubscription: 绑定订阅
 - logout: 登出
 - deleteAccount: 删除账户
*/
