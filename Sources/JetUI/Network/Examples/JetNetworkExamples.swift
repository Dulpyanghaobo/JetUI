//
//  JetNetworkExamples.swift
//  JetUI
//
//  Example API configurations and mock response models for the JetUI Network layer.
//  These are used by the module example app and tests to demonstrate network setup
//  without making real network calls.
//

import Foundation

// MARK: - Example API Configuration

public struct ExampleAPIConfig: APIConfiguration {
    public var baseURL: URL { URL(string: "https://api.example.com/v1")! }
    public var accessToken: String? { nil }

    public init() {}
}

// MARK: - Example Auth Session

public final class ExampleAuthSession: AuthSessionProvider {
    public static let shared = ExampleAuthSession()

    private var _token: String?
    private init() {}

    public var accessToken: String? { _token }

    public func ensureAuthenticated(force: Bool) async -> Bool {
        _token = "mock_access_token_\(Int.random(in: 1000...9999))"
        return true
    }

    public func simulateLogin(token: String) {
        _token = token
    }

    public func simulateLogout() {
        _token = nil
    }
}

// MARK: - Example API Response Models

public struct ExampleUserProfile: Codable {
    public let id: String
    public let displayName: String
    public let email: String
    public let isPro: Bool

    public init(id: String, displayName: String, email: String, isPro: Bool) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.isPro = isPro
    }

    public static let guest = ExampleUserProfile(
        id: "guest_001",
        displayName: "Guest User",
        email: "",
        isPro: false
    )

    public static let proUser = ExampleUserProfile(
        id: "usr_demo_pro",
        displayName: "Demo Pro",
        email: "demo@example.com",
        isPro: true
    )
}

// MARK: - Example Network Error Scenarios

public enum JetNetworkExamples {
    public struct ErrorScenario {
        public let name: String
        public let statusCode: Int
        public let description: String

        public init(name: String, statusCode: Int, description: String) {
            self.name = name
            self.statusCode = statusCode
            self.description = description
        }
    }

    public static let scenarios: [ErrorScenario] = [
        ErrorScenario(
            name: "Unauthorized",
            statusCode: 401,
            description: "Token expired — NetworkCore auto-retries once after re-auth."
        ),
        ErrorScenario(
            name: "Forbidden",
            statusCode: 403,
            description: "Insufficient permissions for this resource."
        ),
        ErrorScenario(
            name: "Not Found",
            statusCode: 404,
            description: "Endpoint or resource does not exist."
        ),
        ErrorScenario(
            name: "Server Error",
            statusCode: 500,
            description: "Transient backend failure — combine with CircuitBreaker for protection."
        ),
    ]
}
