import Foundation
import Testing
@testable import JetUINetworkAuth

@Suite("Network response logging")
struct NetworkLogFormatterTests {
    @Test("Formats JSON and recursively redacts credentials")
    func redactsSensitiveJSONFields() throws {
        let data = try JSONSerialization.data(withJSONObject: [
            "message": "validation failed",
            "accessToken": "top-secret-token",
            "nested": [
                "refresh_token": "refresh-me",
                "field": "readyAt"
            ],
            "items": [
                ["password": "plain-text", "reason": "must be in the future"]
            ]
        ])

        let output = NetworkLogFormatter.formatBody(
            data,
            contentType: "application/problem+json",
            maximumBytes: 16_384
        )

        #expect(output.contains("\"message\" : \"validation failed\""))
        #expect(output.contains("\"field\" : \"readyAt\""))
        #expect(output.contains("\"reason\" : \"must be in the future\""))
        #expect(output.contains("\"accessToken\" : \"<redacted>\""))
        #expect(output.contains("\"refresh_token\" : \"<redacted>\""))
        #expect(output.contains("\"password\" : \"<redacted>\""))
        #expect(!output.contains("top-secret-token"))
        #expect(!output.contains("refresh-me"))
        #expect(!output.contains("plain-text"))
    }

    @Test("Bounds large response bodies")
    func truncatesLargeBodies() {
        let data = Data(String(repeating: "x", count: 128).utf8)

        let output = NetworkLogFormatter.formatBody(
            data,
            contentType: "text/plain",
            maximumBytes: 32
        )

        #expect(output.hasPrefix(String(repeating: "x", count: 32)))
        #expect(output.contains("<truncated 96 bytes>"))
    }

    @Test("Does not attempt to print binary responses")
    func omitsBinaryBodies() {
        let data = Data([0x00, 0xFF, 0x10, 0x80])

        let output = NetworkLogFormatter.formatBody(
            data,
            contentType: "application/octet-stream",
            maximumBytes: 16_384
        )

        #expect(output == "<4 bytes; non-text body omitted>")
    }
}
