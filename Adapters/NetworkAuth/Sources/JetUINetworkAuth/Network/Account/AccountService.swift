//
//  AccountService.swift
//  JetUI
//
//  公共账户/订阅相关的 Service 层
//  直接使用 NetworkCore 发起请求
//

import Foundation

// MARK: - Account Service Protocol

/// 账户服务协议
public protocol AccountServiceProtocol {
    /// 游客登录
    func loginGuest(
        deviceId: String,
        osVersion: String,
        fcmToken: String?,
        source: String,
        deviceInfo: DeviceInfo
    ) async throws -> LoginResult?
    
    /// Apple 绑定
    func bindApple(
        idToken: String,
        nonce: String,
        osVersion: String,
        fcmToken: String?,
        deviceInfo: DeviceInfo
    ) async throws -> LoginResult?
    
    /// 获取用户信息
    func getUserInfo() async throws -> UserInfo?
    
    /// 获取订阅状态
    func getSubscriptionStatus() async throws -> SubscriptionStatus?
    
    /// 绑定订阅
    func bindSubscription(
        signedPayLoad: String,
        storeKitType: Int,
        usageType: Int
    ) async throws
    
    /// 登出
    func logout(refreshToken: String) async throws
    
    /// 删除账户
    func deleteAccount() async throws
}

// MARK: - Default Account Service

/// 默认账户服务实现
/// 直接使用 NetworkCore.shared 发起请求
public final class DefaultAccountService: AccountServiceProtocol {
    
    public static let shared = DefaultAccountService()
    
    private init() {}
    
    public func loginGuest(
        deviceId: String,
        osVersion: String,
        fcmToken: String?,
        source: String,
        deviceInfo: DeviceInfo
    ) async throws -> LoginResult? {
        try await NetworkCore.shared.api(
            AccountTarget.loginGuest(
                deviceId: deviceId,
                osVersion: osVersion,
                fcmToken: fcmToken,
                source: source,
                deviceInfo: deviceInfo
            ),
            LoginResult.self,
            skipAuthRetry: true
        )
    }
    
    public func bindApple(
        idToken: String,
        nonce: String,
        osVersion: String,
        fcmToken: String?,
        deviceInfo: DeviceInfo
    ) async throws -> LoginResult? {
        try await NetworkCore.shared.api(
            AccountTarget.appleBind(
                idToken: idToken,
                nonce: nonce,
                osVersion: osVersion,
                fcmToken: fcmToken,
                deviceInfo: deviceInfo
            ),
            LoginResult.self
        )
    }
    
    public func getUserInfo() async throws -> UserInfo? {
        try await NetworkCore.shared.api(
            AccountTarget.userInfo,
            UserInfo.self
        )
    }
    
    public func getSubscriptionStatus() async throws -> SubscriptionStatus? {
        try await NetworkCore.shared.api(
            AccountTarget.subscriptionStatus,
            SubscriptionStatus.self
        )
    }
    
    public func bindSubscription(
        signedPayLoad: String,
        storeKitType: Int,
        usageType: Int
    ) async throws {
        _ = try await NetworkCore.shared.api(
            AccountTarget.bindSubscription(
                signedPayLoad: signedPayLoad,
                storeKitType: storeKitType,
                usageType: usageType
            ),
            EmptyDecodable.self
        )
    }
    
    public func logout(refreshToken: String) async throws {
        _ = try await NetworkCore.shared.api(
            AccountTarget.logout(refreshToken: refreshToken),
            EmptyDecodable.self
        )
    }
    
    public func deleteAccount() async throws {
        _ = try await NetworkCore.shared.api(
            AccountTarget.deleteAccount,
            EmptyDecodable.self
        )
    }
}

// MARK: - Empty Decodable

/// 用于无返回数据的请求
public struct EmptyDecodable: Decodable {}
