//
//  AuthManager.swift
//  JetUI
//
//  统一认证管理器
//  管理用户登录状态、Token、UserInfo 等
//

import Foundation
import CryptoKit
import UIKit
import KeychainAccess
import Combine
import AuthenticationServices

/// 认证管理器
/// 提供通用的认证管理功能，可被子类扩展以添加业务特定功能
open class AuthManager: NSObject, ObservableObject {
    
    // MARK: - Singleton
    
    public static let shared = AuthManager()
    
    // MARK: - Keychain & Constants
    
    private let base64PrivateKey = "MEECAQAwEwYHKoZIzj0CAQYIKoZIzj0DAQcEJzAlAgEBBCCllo/CayV0sWXz9vAP40Tb03+ZQgd9A8vw+NdEaiHjwQ=="
    
    public let kc: Keychain
    
    public enum KeychainKey {
        public static let loginResult = "auth.loginResult"
        public static let userInfo    = "auth.userInfo"
        public static let deviceId    = "auth.deviceId"
    }
    
    // MARK: - Published Properties
    
    /// App 生命周期内优先使用内存缓存，减少频繁 Keychain I/O
    @Published public private(set) var currentLoginResult: LoginResult? {
        didSet {
            // 写入 Keychain 持久化
            if let lr = currentLoginResult,
               let encoded = try? JSONEncoder().encode(lr) {
                kc[data: KeychainKey.loginResult] = encoded
            } else {
                kc[data: KeychainKey.loginResult] = nil
            }
        }
    }
    
    /// 是否已经通过后端完成登录
    public var isLoggedIn: Bool {
        currentLoginResult != nil
    }
    
    // MARK: - Apple Sign-In State
    
    public var currentNonce: String?
    
    // MARK: - Initialization
    
    public override init() {
        let service = Bundle.main.bundleIdentifier ?? "com.app.auth"
        self.kc = Keychain(service: service)
        
        // 启动时从 Keychain 恢复 loginResult
        if let data = kc[data: KeychainKey.loginResult],
           let lr = try? JSONDecoder().decode(LoginResult.self, from: data) {
            self.currentLoginResult = lr
        } else {
            self.currentLoginResult = nil
        }
        
        super.init()
    }
    
    // MARK: - Login Result Management
    
    public func saveLoginResult(_ result: LoginResult?) {
        self.currentLoginResult = result
    }
    
    // MARK: - User Info Management
    
    public func saveUserInfo(_ info: UserInfo?) {
        if let info = info, let encoded = try? JSONEncoder().encode(info) {
            kc[data: KeychainKey.userInfo] = encoded
        } else {
            kc[KeychainKey.userInfo] = nil
        }
    }
    
    public func getUserInfo() -> UserInfo? {
        guard let stored = kc[data: KeychainKey.userInfo] else { return nil }
        return try? JSONDecoder().decode(UserInfo.self, from: stored)
    }
    
    // MARK: - Device / App Info
    
    public var deviceId: String {
        if let cached = kc[KeychainKey.deviceId] { return cached }
        let idfv = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        kc[KeychainKey.deviceId] = idfv
        return idfv
    }
    
    public var deviceType: String { "iOS" }
    
    public var appVersion: String {
        (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0.0"
    }
    
    public var platform: String { "AppStore" }
    
    /// 创建设备信息对象
    public var deviceInfo: DeviceInfo {
        DeviceInfo(
            deviceId: deviceId,
            deviceType: deviceType,
            appVersion: appVersion,
            platform: platform
        )
    }
    
    // MARK: - Auth Clearing
    
    public func clearAuth() {
        // 1️⃣ 先清内存态
        currentLoginResult = nil
        
        // 2️⃣ 再显式删除 Keychain 里的持久化数据
        do {
            try kc.remove(KeychainKey.loginResult)
        } catch {
            CSLogger.warning("⚠️ Failed to remove loginResult from Keychain: \(error)", category: .general)
        }
        
        do {
            try kc.remove(KeychainKey.userInfo)
        } catch {
            CSLogger.warning("⚠️ Failed to remove userInfo from Keychain: \(error)", category: .general)
        }
    }
    
    // MARK: - Signature Helpers
    
    public func nowMillis() -> String {
        String(Int64(Date().timeIntervalSince1970 * 1000))
    }
    
    public func makeSignContent(
        timestamp: String,
        deviceId: String? = nil,
        deviceType: String? = nil,
        appVersion: String? = nil,
        platform: String? = nil
    ) -> String {
        let did  = deviceId    ?? self.deviceId
        let dt   = deviceType  ?? self.deviceType
        let ver  = appVersion  ?? self.appVersion
        let plat = platform    ?? self.platform
        return "\(did)|\(dt)|\(ver)|\(plat)|\(timestamp)"
    }
    
    /// 计算 ECDSA(P-256, SHA256) 签名：DER → Base64
    public func signDERBase64(for content: String) throws -> String {
        guard let keyData = Data(base64Encoded: base64PrivateKey) else {
            throw NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid base64 private key"])
        }
        let privateKey = try P256.Signing.PrivateKey(derRepresentation: keyData)
        let sig = try privateKey.signature(for: Data(content.utf8))
        return sig.derRepresentation.base64EncodedString()
    }
    
    // MARK: - Apple Sign-In Helpers
    
    /// 用于 SignInWithAppleButton 的 onRequest
    public func configureAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        self.currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
    
    // MARK: - Nonce Helpers
    
    public func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
        return result
    }
    
    public func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map {
            String(format: "%02x", $0)
        }.joined()
    }
}

// MARK: - Entitlement Helpers

extension AuthManager {
    
    /// 当前用户的 Entitlement（从 /app/info 解析出来的）
    public var currentEntitlement: Entitlement? {
        getUserInfo()?.entitlement
    }
    
    /// 当前套餐等级：guest / free / premium ...
    public var currentPlanTier: String {
        currentEntitlement?.planTier ?? "guest"
    }
    
    /// 本地可用空间上限（单位 MB），如果后端没给就默认 5M
    public var currentLocalQuotaMb: Int {
        currentEntitlement?.localQuotaMb ?? 5
    }
    
    /// 是否是付费会员（后端可以通过 isPremium / activePremium 任一为 true）
    public var hasPremium: Bool {
        let ent = currentEntitlement
        return (ent?.isPremium == true) || (ent?.activePremium == true)
    }
}

// MARK: - Cloud Storage Path

extension AuthManager {
    
    /// 当前用户在 Firebase Storage 的根目录
    /// 优先使用后端返回的 cloudStorageRootPath
    /// 如果没有，则基于 deviceId 构造：timestamp/ios/<deviceId>/
    public var currentCloudStorageRootPath: String {
        // 1️⃣ 尝试用后端返回的 path
        if let info = getUserInfo(),
           let raw = info.cloudStorageRootPath?
                .trimmingCharacters(in: .whitespacesAndNewlines),
           !raw.isEmpty {
            
            if raw.hasSuffix("/") {
                return raw
            } else {
                return raw + "/"
            }
        }
        
        // 2️⃣ 没有后端 path，就用 deviceId 生成一个稳定路径
        let deviceId: String
        
        if let info = getUserInfo(),
           let did = info.deviceId,
           !did.isEmpty {
            deviceId = did
        } else if let id = UIDevice.current.identifierForVendor?.uuidString {
            deviceId = id
        } else {
            deviceId = "unknown-device"
        }
        
        return "timestamp/ios/\(deviceId)/"
    }
}
