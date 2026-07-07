//
//  NetworkError.swift
//  JetUI
//
//  网络错误类型定义
//

import Foundation

/// 网络错误类型
public enum NetworkError: Error {
    case invalidResponse(Int)
    case invalidURL
    case noData
    case decodingFailed
    case serverError(message: String, code: Int)
    case unknown
    case invalidFormat                 // 数据结构不符预期
    case serverMessage(String)         // 后端返回了错误 code 或 message
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "无效的 URL"
        case .noData:
            return "没有返回数据"
        case .decodingFailed:
            return "数据解析失败"
        case .serverError(let message, let code):
            return "服务器错误: \(message), 代码: \(code)"
        case .unknown:
            return "未知错误"
        case .invalidFormat:
            return "格式无效"
        case .serverMessage(let msg):
            return "服务错误: \(msg)"
        case .invalidResponse(let code):
            return "无效响应: \(code)"
        }
    }
}

/// API 响应错误
public enum APIError: Error, Decodable {
    /// API 返回的错误
    case apiError(code: Int, message: String)
    /// 网络错误
    case networkError(Error)
    /// 解析错误
    case parsingError(Error)
    /// 未知错误
    case unknown

    enum CodingKeys: String, CodingKey {
        case code
        case message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            let code = try container.decode(Int.self, forKey: .code)
            let message = try container.decode(String.self, forKey: .message)
            self = .apiError(code: code, message: message)
        } catch {
            throw DecodingError.dataCorruptedError(
                forKey: .code,
                in: container,
                debugDescription: "Cannot decode APIError. Expected code and message."
            )
        }
    }

    /// 从 API 响应中创建错误
    public static func from(response: [String: Any]) -> APIError? {
        guard let code = response["code"] as? Int else { return nil }
        let message = response["message"] as? String ?? "Unknown error"
        return .apiError(code: code, message: message)
    }

    /// 获取错误描述
    public var localizedDescription: String {
        switch self {
        case .apiError(let code, let message):
            return "[\(code)] \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .parsingError(let error):
            return "Parsing error: \(error.localizedDescription)"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}