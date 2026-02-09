//
//  AccountTarget.swift
//  JetUI
//
//  公共账户/订阅相关的 API Target
//  包括：登录、用户信息、订阅状态、绑定订阅、Apple 绑定、登出、删除账户
//

import Foundation
import Moya

// MARK: - Account Target

/// 账户/订阅相关的 API 端点
public enum AccountTarget {
    // 认证
    case loginGuest(deviceId: String, osVersion: String, fcmToken: String?, source: String, deviceInfo: DeviceInfo)
    case appleBind(idToken: String, nonce: String, osVersion: String, fcmToken: String?, deviceInfo: DeviceInfo)
    case logout(refreshToken: String)
    case deleteAccount
    
    // 用户信息
    case userInfo
    
    // 订阅
    case subscriptionStatus
    case bindSubscription(signedPayLoad: String, storeKitType: Int, usageType: Int)
}

// MARK: - Device Info

/// 设备信息，由主 App 提供
public struct DeviceInfo {
    public let deviceId: String
    public let deviceType: String
    public let appVersion: String
    public let platform: String
    
    public init(deviceId: String, deviceType: String, appVersion: String, platform: String) {
        self.deviceId = deviceId
        self.deviceType = deviceType
        self.appVersion = appVersion
        self.platform = platform
    }
}

// MARK: - Configuration

/// API 配置协议
public protocol AccountAPIConfiguration {
    var baseURL: URL { get }
    var tokenProvider: (() -> String?)? { get }
}

/// 默认配置
public struct DefaultAccountAPIConfiguration: AccountAPIConfiguration {
    public let baseURL: URL
    public let tokenProvider: (() -> String?)?
    
    public init(baseURL: URL, tokenProvider: (() -> String?)? = nil) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
    }
}

// MARK: - Static Configuration

extension AccountTarget {
    /// 配置项，可选设置。如果未设置，使用默认 baseURL
    public static var configuration: AccountAPIConfiguration?
    
    /// 默认 baseURL，与 InternalTarget 保持一致
    private static let defaultBaseURL = URL(string: "https://waterappbackend-743086285375.us-central1.run.app")!
}

// MARK: - TargetType Conformance

extension AccountTarget: TargetType {
    
    public var baseURL: URL {
        // 如果配置了自定义 baseURL，使用自定义的；否则使用默认的
        return AccountTarget.configuration?.baseURL ?? AccountTarget.defaultBaseURL
    }
    
    public var path: String {
        switch self {
        case .loginGuest:
            return "/api/app/auth/login/guest"
        case .appleBind:
            return "/api/app/auth/apple/bind"
        case .logout:
            return "/api/app/auth/logout"
        case .deleteAccount:
            return "/api/app/auth/account"
        case .userInfo:
            return "/api/app/info"
        case .subscriptionStatus:
            return "/api/app/subscription/status"
        case .bindSubscription:
            return "/api/app/subscription/bind/apple"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .loginGuest, .appleBind, .logout, .bindSubscription:
            return .post
        case .deleteAccount:
            return .delete
        case .userInfo, .subscriptionStatus:
            return .get
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .loginGuest(let deviceId, let osVersion, let fcmToken, let source, let deviceInfo):
            let params: [String: Any] = [
                "deviceId": deviceId,
                "deviceType": deviceInfo.deviceType,
                "appVersion": deviceInfo.appVersion,
                "platform": deviceInfo.platform,
                "osVersion": osVersion,
                "fcmToken": fcmToken ?? "",
                "source": source
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .appleBind(let idToken, let nonce, let osVersion, let fcmToken, let deviceInfo):
            let params: [String: Any] = [
                "idToken": idToken,
                "nonce": nonce,
                "deviceId": deviceInfo.deviceId,
                "deviceType": deviceInfo.deviceType,
                "osVersion": osVersion,
                "appVersion": deviceInfo.appVersion,
                "platform": deviceInfo.platform,
                "fcmToken": fcmToken ?? ""
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .logout(let refreshToken):
            let params: [String: Any] = [
                "refreshToken": refreshToken
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .bindSubscription(let payLoad, let storeKitType, let usageType):
            let params: [String: Any] = [
                "signedPayLoad": payLoad,
                "storeKitType": storeKitType,
                "subscriptionUsageType": usageType
            ]
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .deleteAccount, .userInfo, .subscriptionStatus:
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        var h: [String: String] = ["Accept": "application/json"]
        
        // 添加 Content-Type
        switch self {
        case .loginGuest, .appleBind, .logout, .bindSubscription:
            h["Content-Type"] = "application/json"
        default:
            break
        }
        
        // 添加 Authorization header
        switch self {
        case .loginGuest:
            // 登录接口不需要 token
            return h
        default:
            // 优先使用配置的 tokenProvider，否则尝试从 AuthManager 获取
            if let tokenProvider = AccountTarget.configuration?.tokenProvider,
               let token = tokenProvider() {
                h["Authorization"] = "Bearer \(token)"
            } else if let token = AuthManager.shared.currentLoginResult?.token {
                h["Authorization"] = "Bearer \(token)"
            }
            return h
        }
    }
    
    public var sampleData: Data {
        Data()
    }
}