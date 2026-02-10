//
//  AuthModels.swift
//  JetUI
//
//  认证相关的数据模型
//

import Foundation
/// 绑定订阅请求参数
public struct BindSubscriptionRequest: Encodable {
    public let signedPayLoad: String
    public let storeKitType: Int
    public let usageType: Int
    
    public init(signedPayLoad: String, storeKitType: Int, usageType: Int) {
        self.signedPayLoad = signedPayLoad
        self.storeKitType = storeKitType
        self.usageType = usageType
    }
}

// MARK: - Apple 绑定请求

/// Apple Sign In 绑定请求
public struct AppleBindRequest: Encodable {
    public let idToken: String
    public let nonce: String
    public let osVersion: String
    public let fcmToken: String?
    
    public init(idToken: String, nonce: String, osVersion: String, fcmToken: String? = nil) {
        self.idToken = idToken
        self.nonce = nonce
        self.osVersion = osVersion
        self.fcmToken = fcmToken
    }
}

// MARK: - 游客登录请求

/// 游客登录请求
public struct GuestLoginRequest: Encodable {
    public let deviceId: String
    public let osVersion: String
    public let fcmToken: String?
    public let source: String
    
    public init(deviceId: String, osVersion: String, fcmToken: String? = nil, source: String = "ios") {
        self.deviceId = deviceId
        self.osVersion = osVersion
        self.fcmToken = fcmToken
        self.source = source
    }
}
