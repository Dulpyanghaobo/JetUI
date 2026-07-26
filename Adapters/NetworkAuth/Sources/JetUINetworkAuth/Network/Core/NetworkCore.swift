//
//  NetworkCore.swift
//  JetUI
//
//  URLSession based network core with a lightweight TargetType abstraction.
//

import Foundation
import JetUICore

// MARK: - Target Abstractions

public enum JetMoya {
    public enum Method: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
}

public protocol JetTargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: JetMoya.Method { get }
    var task: JetNetworkTask { get }
    var headers: [String: String]? { get }
    var sampleData: Data { get }
}

public enum JetNetworkTask {
    case requestPlain
    case requestData(Data)
    case requestParameters(parameters: [String: Any], encoding: JetParameterEncoding)
}

public protocol JetParameterEncoding {
    func encode(_ request: URLRequest, parameters: [String: Any]) throws -> URLRequest
}

public struct JetJSONEncoding: JetParameterEncoding {
    public static let `default` = JetJSONEncoding()

    public init() {}

    public func encode(_ request: URLRequest, parameters: [String: Any]) throws -> URLRequest {
        var request = request
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}

// MARK: - Auth Session

/// 认证会话协议 - 由宿主 App 实现
public protocol AuthSessionProvider: AnyObject {
    /// 确保已认证，可选择强制刷新
    func ensureAuthenticated(force: Bool) async -> Bool

    /// 获取当前访问令牌
    var accessToken: String? { get }
}

// MARK: - Network Logging

public struct NetworkLoggingConfiguration: Sendable {
    public var includesBodies: Bool
    public var maximumBodyBytes: Int

    public init(
        includesBodies: Bool,
        maximumBodyBytes: Int = 16_384
    ) {
        self.includesBodies = includesBodies
        self.maximumBodyBytes = max(1, maximumBodyBytes)
    }

    public static var `default`: NetworkLoggingConfiguration {
        #if DEBUG
        NetworkLoggingConfiguration(includesBodies: true)
        #else
        NetworkLoggingConfiguration(includesBodies: false)
        #endif
    }
}

// MARK: - Network Core

public final class NetworkCore {
    public static let shared = NetworkCore()

    /// 认证会话提供者（由宿主 App 注入）
    public weak var authSession: AuthSessionProvider?

    /// Response/request body logging is enabled by default for Debug builds.
    /// Sensitive JSON fields are recursively redacted before they reach OSLog.
    public var loggingConfiguration: NetworkLoggingConfiguration = .default

    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    /// 通用请求方法（支持任何 TargetType）
    public func request<T: Decodable>(
        _ target: any JetTargetType,
        _ type: T.Type = T.self
    ) async throws -> T {
        let response = try await perform(target)
        return try JSONDecoder().decode(T.self, from: response.data)
    }

    /// API 请求方法，自动处理 APIResponse 包装和错误
    public func api<T: Decodable>(
        _ target: any JetTargetType,
        _ type: T.Type = T.self,
        skipAuthRetry: Bool = false
    ) async throws -> T? {
        func decode(_ response: NetworkResponse) throws -> T? {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: response.data)
            guard apiResponse.code == 200 else {
                let message = apiResponse.message ?? "Unknown error"
                throw APIError.apiError(code: apiResponse.code, message: message)
            }
            return apiResponse.data
        }

        do {
            return try decode(try await perform(target))
        } catch let error as NetworkError {
            if case .invalidResponse(let status) = error,
               (status == 401 || status == 403),
               skipAuthRetry == false,
               let session = authSession {
                _ = await session.ensureAuthenticated(force: true)
                return try decode(try await perform(target))
            }
            throw error
        }
    }

    private func perform(_ target: any JetTargetType) async throws -> NetworkResponse {
        let request = try makeRequest(for: target)
        logRequest(request, target: target)

        do {
            let (data, urlResponse) = try await session.data(for: request)
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw NetworkError.invalidResponse(-1)
            }

            logResponse(data: data, response: httpResponse, target: target)

            guard 200..<300 ~= httpResponse.statusCode else {
                throw NetworkError.invalidResponse(httpResponse.statusCode)
            }

            return NetworkResponse(data: data, statusCode: httpResponse.statusCode, request: request)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.serverMessage(error.localizedDescription)
        }
    }

    private func makeRequest(for target: any JetTargetType) throws -> URLRequest {
        let url = target.baseURL.appendingPathComponent(target.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = target.method.rawValue
        target.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        switch target.task {
        case .requestPlain:
            return request
        case .requestData(let data):
            request.httpBody = data
            return request
        case .requestParameters(let parameters, let encoding):
            return try encoding.encode(request, parameters: parameters)
        }
    }

    private func logRequest(_ request: URLRequest, target: any JetTargetType) {
        CSLogger.info("🚀 \(request.httpMethod ?? "") \(request.url?.path ?? target.path)", category: .network)
        if let headers = request.allHTTPHeaderFields {
            let safeHeaders = headers.mapValues { _ in "<redacted>" }
            CSLogger.debug("📋 Headers: \(safeHeaders)", category: .network)
        }
        if let body = request.httpBody {
            CSLogger.debug("📦 Request body: \(body.count) bytes", category: .network)
            if loggingConfiguration.includesBodies {
                let formattedBody = NetworkLogFormatter.formatBody(
                    body,
                    contentType: request.value(forHTTPHeaderField: "Content-Type"),
                    maximumBytes: loggingConfiguration.maximumBodyBytes
                )
                CSLogger.debug(
                    "📤 Request JSON:\n\(formattedBody)",
                    category: .network
                )
            }
        }
    }

    private func logResponse(data: Data, response: HTTPURLResponse, target: any JetTargetType) {
        let symbol = 200..<300 ~= response.statusCode ? "✅" : "❌"
        CSLogger.debug(
            "\(symbol) [\(response.statusCode)] \(response.url?.path ?? target.path) (\(data.count) bytes)",
            category: .network
        )
        if loggingConfiguration.includesBodies {
            let formattedBody = NetworkLogFormatter.formatBody(
                data,
                contentType: response.value(forHTTPHeaderField: "Content-Type"),
                maximumBytes: loggingConfiguration.maximumBodyBytes
            )
            CSLogger.debug(
                "📥 Response body:\n\(formattedBody)",
                category: .network
            )
        }
    }
}

enum NetworkLogFormatter {
    private static let sensitiveKeys: Set<String> = [
        "authorization",
        "cookie",
        "setcookie",
        "password",
        "passwd",
        "pwd",
        "token",
        "accesstoken",
        "refreshtoken",
        "idtoken",
        "sessiontoken",
        "apikey",
        "xapikey",
        "secret",
        "clientsecret",
        "credential",
        "credentials"
    ]

    static func formatBody(
        _ data: Data,
        contentType: String?,
        maximumBytes: Int
    ) -> String {
        guard !data.isEmpty else {
            return "<empty>"
        }

        if isJSON(data: data, contentType: contentType),
           let object = try? JSONSerialization.jsonObject(with: data),
           JSONSerialization.isValidJSONObject(object),
           let sanitizedData = try? JSONSerialization.data(
               withJSONObject: redact(object),
               options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
           ) {
            return boundedText(sanitizedData, maximumBytes: maximumBytes)
        }

        if isText(contentType: contentType), String(data: data, encoding: .utf8) != nil {
            return boundedText(data, maximumBytes: maximumBytes)
        }

        return "<\(data.count) bytes; non-text body omitted>"
    }

    private static func isJSON(data: Data, contentType: String?) -> Bool {
        if contentType?.lowercased().contains("json") == true {
            return true
        }
        guard let firstByte = data.first(where: {
            ![0x09, 0x0A, 0x0D, 0x20].contains($0)
        }) else {
            return false
        }
        return firstByte == 0x7B || firstByte == 0x5B
    }

    private static func isText(contentType: String?) -> Bool {
        guard let contentType = contentType?.lowercased() else {
            return true
        }
        return contentType.hasPrefix("text/")
            || contentType.contains("xml")
            || contentType.contains("javascript")
            || contentType.contains("x-www-form-urlencoded")
    }

    private static func redact(_ value: Any) -> Any {
        if let dictionary = value as? [String: Any] {
            return dictionary.reduce(into: [String: Any]()) { result, entry in
                if isSensitive(entry.key) {
                    result[entry.key] = "<redacted>"
                } else {
                    result[entry.key] = redact(entry.value)
                }
            }
        }
        if let array = value as? [Any] {
            return array.map(redact)
        }
        return value
    }

    private static func isSensitive(_ key: String) -> Bool {
        let normalized = key
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
        return sensitiveKeys.contains(normalized)
            || normalized.hasSuffix("token")
            || normalized.hasSuffix("password")
            || normalized.hasSuffix("secret")
    }

    private static func boundedText(_ data: Data, maximumBytes: Int) -> String {
        let limit = max(1, maximumBytes)
        guard data.count > limit else {
            return String(decoding: data, as: UTF8.self)
        }
        let omittedByteCount = data.count - limit
        let prefix = String(decoding: data.prefix(limit), as: UTF8.self)
        return "\(prefix)\n… <truncated \(omittedByteCount) bytes>"
    }
}

public struct NetworkResponse {
    public let data: Data
    public let statusCode: Int
    public let request: URLRequest
}
