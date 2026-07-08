import UIKit
import XCTest
@testable import JetUI

final class JetDiskImageLoaderTests: XCTestCase {
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("JetDiskImageLoaderTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        JetURLProtocolStub.handler = nil
        try? FileManager.default.removeItem(at: tempDirectory)
        tempDirectory = nil
        try super.tearDownWithError()
    }

    func testDownloadedImageIsPersistedAndLoadedFromDiskByNewLoader() async throws {
        let url = URL(string: "https://example.com/template.png")!
        let imageData = try XCTUnwrap(Self.pngData())
        var networkHits = 0
        JetURLProtocolStub.handler = { request in
            networkHits += 1
            return (
                HTTPURLResponse(
                    url: try XCTUnwrap(request.url),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                imageData
            )
        }
        let loader = JetDiskImageLoader(
            diskCacheDirectory: tempDirectory,
            session: Self.stubbedSession()
        )

        let downloaded = await loader.loadAsync(url: url)

        XCTAssertNotNil(downloaded)

        JetURLProtocolStub.handler = { request in
            XCTFail("Expected disk cache hit, not network request to \(request.url?.absoluteString ?? "")")
            throw URLError(.notConnectedToInternet)
        }
        let secondLoader = JetDiskImageLoader(
            diskCacheDirectory: tempDirectory,
            session: Self.stubbedSession()
        )

        let cached = await secondLoader.loadAsync(url: url)

        XCTAssertNotNil(cached)
        XCTAssertEqual(networkHits, 1)
    }

    func testClearCacheOlderThanRemovesExpiredDiskEntries() async throws {
        let url = URL(string: "https://example.com/expired.png")!
        let imageData = try XCTUnwrap(Self.pngData())
        JetURLProtocolStub.handler = { request in
            (
                HTTPURLResponse(
                    url: try XCTUnwrap(request.url),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                imageData
            )
        }
        let loader = JetDiskImageLoader(
            diskCacheDirectory: tempDirectory,
            session: Self.stubbedSession()
        )

        let loaded = await loader.loadAsync(url: url)
        XCTAssertNotNil(loaded)
        let files = try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil)
        let cacheFile = try XCTUnwrap(files.first)
        try FileManager.default.setAttributes(
            [.modificationDate: Date(timeIntervalSince1970: 0)],
            ofItemAtPath: cacheFile.path
        )

        loader.clearCache(olderThan: Date(timeIntervalSince1970: 10))

        XCTAssertTrue(try FileManager.default.contentsOfDirectory(at: tempDirectory, includingPropertiesForKeys: nil).isEmpty)
    }

    func testCancelDownloadStopsInFlightRequest() {
        let url = URL(string: "https://example.com/slow.png")!
        let stopped = expectation(description: "URL loading stopped")
        JetURLProtocolStub.startHandler = { _ in }
        JetURLProtocolStub.stopHandler = {
            stopped.fulfill()
        }
        let loader = JetDiskImageLoader(
            diskCacheDirectory: tempDirectory,
            session: Self.stubbedSession()
        )

        loader.load(url: url) { _ in }
        loader.cancelDownload(for: url)

        wait(for: [stopped], timeout: 2)
        JetURLProtocolStub.startHandler = nil
        JetURLProtocolStub.stopHandler = nil
    }

    private static func stubbedSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [JetURLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    private static func pngData() -> Data? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2))
        return renderer.image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
        }.pngData()
    }
}

private final class JetURLProtocolStub: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    static var startHandler: ((URLRequest) -> Void)?
    static var stopHandler: (() -> Void)?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.startHandler?(request)
        guard let handler = Self.handler else { return }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        Self.stopHandler?()
    }
}
