//
//  JetUI+NetworkAuth.swift
//  JetUINetworkAuth
//
//  Compatibility facade for apps that import both JetUI and JetUINetworkAuth.
//

import Foundation
import JetUI

public extension JetUI {
    /// 配置认证 API
    /// - Parameter configuration: API 配置
    static func configureAuth(_ configuration: APIConfiguration) {
        AuthTarget.configuration = configuration
        NetworkCore.shared.authSession = AuthSession.shared
    }

    /// 配置账户 API
    /// - Parameters:
    ///   - baseURL: API 服务器地址
    ///   - tokenProvider: 获取当前 Token 的闭包
    static func configureAccount(baseURL: URL, tokenProvider: (() -> String?)?) {
        AccountTarget.configuration = DefaultAccountAPIConfiguration(
            baseURL: baseURL,
            tokenProvider: tokenProvider
        )
    }
}
