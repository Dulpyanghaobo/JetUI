//
//  AuthSession.swift
//  JetUI
//
//  认证会话管理，使用 Keychain 安全存储 Token
//

import Foundation
import KeychainAccess

/// 认证会话管理
public final class AuthSession: AuthSessionProvider {
    
    // MARK: - Singleton
    
    public static let shared = AuthSession()
    
    // MARK: - Keychain Keys
    
    private enum KeychainKey {
        static let accessToken = "jet_access_token"
        static let refreshToken = "jet_refresh_token"
        static let userId = "jet_user_id"
    }
    
    // MARK: - Properties
    
    private let keychain: Keychain
    
    /// 当前访问令牌
    public var accessToken: String? {
        get { try? keychain.get(KeychainKey.accessToken) }
        set {
            if let value = newValue {
                try? keychain.set(value, key: KeychainKey.accessToken)
            } else {
                try? keychain.remove(KeychainKey.accessToken)
            }
        }
    }
    
    /// 刷新令牌
    public var refreshToken: String? {
        get { try? keychain.get(KeychainKey.refreshToken) }
        set {
            if let value = newValue {
                try? keychain.set(value, key: KeychainKey.refreshToken)
            } else {
                try? keychain.remove(KeychainKey.refreshToken)
            }
        }
    }
    
    /// 用户 ID
    public var userId: String? {
        get { try? keychain.get(KeychainKey.userId) }
        set {
            if let value = newValue {
                try? keychain.set(value, key: KeychainKey.userId)
            } else {
                try? keychain.remove(KeychainKey.userId)
            }
        }
    }
    
    /// 是否已登录
    public var isLoggedIn: Bool {
        accessToken != nil
    }
    
    // MARK: - Init
    
    private init() {
        // 使用 bundle identifier 作为 keychain service
        let service = Bundle.main.bundleIdentifier ?? "com.jetui.auth"
        self.keychain = Keychain(service: service)
            .accessibility(.afterFirstUnlock)
    }
    
    // MARK: - AuthSessionProvider
    
    /// 确保已认证
    /// - Parameter force: 是否强制刷新 Token
    /// - Returns: 是否成功
    public func ensureAuthenticated(force: Bool) async -> Bool {
        guard force else {
            return isLoggedIn
        }
        
        // 如果有 refresh token，尝试刷新
        // 这里只是占位，实际刷新逻辑需要由宿主 App 实现
        CSLogger.info("AuthSession.ensureAuthenticated called with force=\(force)", category: .auth)
        
        return isLoggedIn
    }
    
    // MARK: - Token Management
    
    /// 保存登录结果
    /// - Parameter result: 登录结果
    public func save(_ result: LoginResult) {
        accessToken = result.accessToken
        refreshToken = result.refreshToken
        userId = result.userId
        
        CSLogger.info("AuthSession: Tokens saved", category: .auth)
    }
    
    /// 清除所有凭证
    public func clear() {
        accessToken = nil
        refreshToken = nil
        userId = nil
        
        CSLogger.info("AuthSession: Tokens cleared", category: .auth)
    }
    
    /// 刷新访问令牌
    /// - Returns: 是否成功
    @discardableResult
    public func refreshAccessToken() async -> Bool {
        guard let refresh = refreshToken else {
            CSLogger.warning("AuthSession: No refresh token available", category: .auth)
            return false
        }
        
        // 这里应该调用刷新 token 的 API
        // 由于具体 API 由宿主 App 决定，这里只是框架
        CSLogger.info("AuthSession: Attempting to refresh token", category: .auth)
        
        // 占位：实际实现需要调用 API
        _ = refresh
        
        return false
    }
}

// MARK: - APIConfiguration Conformance

extension AuthSession: APIConfiguration {
    public var baseURL: URL {
        // 默认 base URL，应该由宿主 App 配置
        URL(string: "https://api.example.com")!
    }
}
