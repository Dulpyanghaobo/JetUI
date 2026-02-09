//
//  NetworkCore.swift
//  JetUI
//
//  基于 Moya 的网络核心，提供类型安全的 API 请求
//

import Foundation
import Moya

/// 认证会话协议 - 由宿主 App 实现
public protocol AuthSessionProvider: AnyObject {
    /// 确保已认证，可选择强制刷新
    func ensureAuthenticated(force: Bool) async -> Bool
    
    /// 获取当前访问令牌
    var accessToken: String? { get }
}

/// 网络日志插件
public struct NetworkLoggerPlugin: PluginType {
    
    public init() {}
    
    public func willSend(_ request: RequestType, target: TargetType) {
        guard let r = request.request else { return }
        
        let urlString = r.url?.absoluteString ?? target.baseURL.absoluteString + target.path
        
        CSLogger.info("🚀 \(r.httpMethod ?? "") \(urlString)", category: .network)
        if let headers = r.allHTTPHeaderFields {
            CSLogger.debug("📋 Headers: \(headers)", category: .network)
        }
        if let body = r.httpBody, let s = String(data: body, encoding: .utf8) {
            CSLogger.debug("📦 Body: \(s)", category: .network)
        }
    }

    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .success(let response):
            let urlString = response.request?.url?.absoluteString ?? target.path
            CSLogger.debug("✅ [\(response.statusCode)] \(urlString)", category: .network)

            if let bodyString = String(data: response.data, encoding: .utf8) {
                CSLogger.debug("📨 Response Body: \(bodyString)", category: .network)
            }

        case .failure(let err):
            CSLogger.error("❌ \(err.localizedDescription)", category: .network)
        }
    }
}

/// 网络核心
public final class NetworkCore {

    public static let shared = NetworkCore()
    
    /// 认证会话提供者（由宿主 App 注入）
    public weak var authSession: AuthSessionProvider?
    
    private let provider: MoyaProvider<MultiTarget>

    private init() {
        let plugins: [PluginType] = [
            NetworkLoggerPlugin()
        ]
        provider = MoyaProvider<MultiTarget>(plugins: plugins)
    }

    /// 通用请求方法（支持任何 TargetType）
    public func request<T: Decodable>(_ target: any TargetType,
                                      _ type: T.Type = T.self) async throws -> T {
        let response = try await provider.asyncRequest(.target(target))
        return try JSONDecoder().decode(T.self, from: response.data)
    }
    
    /// API 请求方法，自动处理 APIResponse 包装和错误
    /// - Parameters:
    ///   - target: API 目标
    ///   - type: 期望的响应数据类型
    ///   - skipAuthRetry: 是否跳过认证重试
    /// - Returns: 解码后的数据（可能为 nil）
    public func api<T: Decodable>(_ target: any TargetType,
                                  _ type: T.Type = T.self,
                                  skipAuthRetry: Bool = false) async throws -> T? {
        func decode(_ resp: Response) throws -> T? {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: resp.data)
            guard apiResponse.code == 200 else {
                let msg = apiResponse.message ?? "Unknown error"
                throw APIError.apiError(code: apiResponse.code, message: msg)
            }
            return apiResponse.data
        }
        
        do {
            let resp = try await provider.asyncRequest(.target(target))
            return try decode(resp)
        } catch let e as NetworkError {
            // HTTP 层面的 401/403：触发一次重登并重试一次
            if case .invalidResponse(let status) = e,
               (status == 401 || status == 403),
               skipAuthRetry == false,
               let session = authSession {
                _ = await session.ensureAuthenticated(force: true)
                let retry = try await provider.asyncRequest(.target(target))
                return try decode(retry)
            }
            throw e
        }
    }
}

// MARK: - MoyaProvider Async Extension

private extension MoyaProvider where Target == MultiTarget {
    func asyncRequest(_ target: MultiTarget) async throws -> Response {
        try await withCheckedThrowingContinuation { cont in
            self.request(target) { result in
                switch result {
                case .success(let resp):
                    if 200..<300 ~= resp.statusCode {
                        cont.resume(returning: resp)
                    } else {
                        cont.resume(throwing: NetworkError.invalidResponse(resp.statusCode))
                    }
                case .failure(let err):
                    cont.resume(throwing: err)
                }
            }
        }
    }
}