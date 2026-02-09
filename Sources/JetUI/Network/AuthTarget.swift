//
//  AuthTarget.swift
//  JetUI
//
//  认证相关的 API 端点定义
//

import Foundation
import Moya

/// API 基础配置协议
public protocol APIConfiguration {
    /// API 基础 URL
    var baseURL: URL { get }
    /// 获取访问令牌
    var accessToken: String? { get }
}

/// 认证相关 API 端点
public enum AuthTarget {
    // MARK: - 账户
    /// 游客登录
    case loginGuest(deviceId: String, osVersion: String, fcmToken: String?, source: String)
    /// 获取用户信息
    case userInfo
    /// Apple Sign In 绑定
    case appleBind(idToken: String, nonce: String, osVersion: String, fcmToken: String?)
    /// 登出
    case logout(refreshToken: String)
    /// 删除账户
    case deleteAccount
    
    // MARK: - 订阅
    /// 获取订阅状态
    case subscriptionStatus
    /// 绑定订阅
    case bindSubscription(signedPayLoad: String, storeKitType: Int, usageType: Int)
}

// MARK: - AuthTarget Configuration

extension AuthTarget {
    /// 静态配置（由宿主 App 注入）
    public static var configuration: APIConfiguration?
}

// MARK: - TargetType

extension AuthTarget: TargetType {
    
    public var baseURL: URL {
        guard let config = AuthTarget.configuration else {
            fatalError("AuthTarget.configuration must be set before using AuthTarget")
        }
        return config.baseURL
    }
    
    public var path: String {
        switch self {
        case .loginGuest:
            return "/api/v1/auth/guest"
        case .userInfo:
            return "/api/v1/user/info"
        case .appleBind:
            return "/api/v1/auth/apple"
        case .logout:
            return "/api/v1/auth/logout"
        case .deleteAccount:
            return "/api/v1/user/delete"
        case .subscriptionStatus:
            return "/api/v1/subscription/status"
        case .bindSubscription:
            return "/api/v1/subscription/bind"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .userInfo, .subscriptionStatus:
            return .get
        case .loginGuest, .appleBind, .bindSubscription:
            return .post
        case .logout:
            return .post
        case .deleteAccount:
            return .delete
        }
    }
    
    public var task: Task {
        switch self {
        case .loginGuest(let deviceId, let osVersion, let fcmToken, let source):
            var params: [String: Any] = [
                "device_id": deviceId,
                "os_version": osVersion,
                "source": source
            ]
            if let token = fcmToken {
                params["fcm_token"] = token
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .appleBind(let idToken, let nonce, let osVersion, let fcmToken):
            var params: [String: Any] = [
                "id_token": idToken,
                "nonce": nonce,
                "os_version": osVersion
            ]
            if let token = fcmToken {
                params["fcm_token"] = token
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
            
        case .logout(let refreshToken):
            return .requestParameters(
                parameters: ["refresh_token": refreshToken],
                encoding: JSONEncoding.default
            )
            
        case .bindSubscription(let signedPayLoad, let storeKitType, let usageType):
            return .requestParameters(
                parameters: [
                    "signed_payload": signedPayLoad,
                    "storekit_type": storeKitType,
                    "usage_type": usageType
                ],
                encoding: JSONEncoding.default
            )
            
        case .userInfo, .subscriptionStatus, .deleteAccount:
            return .requestPlain
        }
    }
    
    public var headers: [String: String]? {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // 需要认证的接口添加 Token
        if requiresAuth, let token = AuthTarget.configuration?.accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
    
    /// 是否需要认证
    private var requiresAuth: Bool {
        switch self {
        case .loginGuest:
            return false
        default:
            return true
        }
    }
}