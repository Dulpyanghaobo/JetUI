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
    ///   - paths: 自定义账户/订阅端点，默认保持 JetUI/TimeProof 行为
    static func configureAccount(
        baseURL: URL,
        tokenProvider: (() -> String?)?,
        paths: AccountEndpointPaths = .default
    ) {
        AccountTarget.configuration = DefaultAccountAPIConfiguration(
            baseURL: baseURL,
            tokenProvider: tokenProvider,
            paths: paths
        )
    }
}
