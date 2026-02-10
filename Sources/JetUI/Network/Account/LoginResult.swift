//
//  LoginResult.swift
//  FaxByScanning
//
//  Created by i564407 on 7/25/25.
//
import Foundation

public struct LoginResult: Codable {
    public var token: String?
    public var tokenType: String?
    /// 过期时间 (单位: 秒)
    public var expiration: Int64?
    public var refreshToken: String?
    public var accessToken: String?
    
    public var userId: String?
    public var appleBound: Bool?
    public var userInfo: UserInfo?
}

// MARK: - User Info ----------------------------------------------------------

public struct UserInfo: Codable {
    public let id: Int?
    public let deviceId: String?
    public let sendNoticeStatus: Bool?
    public let receiveNoticeStatus: Bool?
    public let nickName: String?
    public let subscriptions: [Subscription]?
    public let name: String?
    public let email: String?
    public let phone: String?
    public let entitlement: Entitlement?
    public let cloudStorageRootPath: String?
    public let subscribed: Bool?
    public var credits: UserCredits?
    public var hasSignedInToday: Bool?  // 改为 var，允许 Debug 模式修改
    
    enum CodingKeys: String, CodingKey {
        case id, deviceId, sendNoticeStatus, receiveNoticeStatus
        case nickName, subscriptions, name, email, phone
        case entitlement, cloudStorageRootPath, subscribed, credits
        case hasSignedInToday
    }
    
    /// 兼容别名：creditsInfo 指向 credits
    public var creditsInfo: UserCredits? {
        get { credits }
        set { credits = newValue }
    }
}

// MARK: - User Credits -------------------------------------------------------

public struct UserCredits: Codable {
    public let userId: Int
    public var creditsAiTemplate: Int
    public var creditsRemoveLogo: Int
    public var creditsPdfExport: Int
    public var creditsHdExport: Int
    public var creditsBatchExport: Int
    public let updatedAt: String?
    public let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case userId
        case creditsAiTemplate
        case creditsRemoveLogo
        case creditsPdfExport
        case creditsHdExport
        case creditsBatchExport
        case updatedAt
        case createdAt
    }
}

// MARK: - Subscription -------------------------------------------------------
public struct Subscription: Codable {
    public let id: Int?
    public let userId: Int?
    public let subscriptionId: String?
    public let purchaseToken: String?
    public let platform: String?
    public let subscriptionUsageType: Int?
    public let expireTime: String?
}

// MARK: - Entitlement
public struct Entitlement: Codable {
    public let id: Int?
    public let isPremium: Bool?
    public let premiumSource: String?
    public let premiumExpireTime: String?
    public let watermarkQuota: Int?
    public let quotaResetTime: String?
    public let adFree: Bool?
    public let planTier: String?
    public let localQuotaMb: Int?
    public let maxFolderCount: Int?
    public let cloudBackupEnabled: Bool?
    public let aiAnalysisEnabled: Bool?
    public let proTemplatesEnabled: Bool?
    public let createTime: String?
    public let modifyTime: String?
    public let activePremium: Bool?
}

public struct SubscriptionStatus: Codable {
    public var subscriptionUsageType: Int32?
    public var subscriptionId: String?
    public var transactionId: String?
    public var sendSubscribed: Bool?
    public var receiveSubscribed: Bool?
    public var expireTime: [Int]?
}
