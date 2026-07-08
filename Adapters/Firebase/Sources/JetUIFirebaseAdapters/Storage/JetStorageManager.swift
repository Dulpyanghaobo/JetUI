//
//  JetStorageManager.swift
//  JetUI
//
//  Firebase-backed JetCloudStorageProvider.
//  Register at startup:
//  ```swift
//  JetCloudStorage.shared.register(JetStorageManager.shared)
//  ```
//

import Foundation
import UIKit
import FirebaseStorage
import JetUI

/// Resolves the current Firebase Storage root path for the active app/user.
public struct JetStorageRootPathProvider {
    private let resolveRootPath: () -> String

    public init(_ resolveRootPath: @escaping () -> String) {
        self.resolveRootPath = resolveRootPath
    }

    public func currentRootPath() -> String {
        Self.normalizedRootPath(resolveRootPath())
    }

    public static var deviceDefault: JetStorageRootPathProvider {
        JetStorageRootPathProvider {
            deviceRootPath()
        }
    }

    public static func deviceRootPath(deviceId: String? = UIDevice.current.identifierForVendor?.uuidString) -> String {
        let resolvedDeviceId = deviceId?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nonEmpty ?? "unknown-device"
        return "timestamp/ios/\(resolvedDeviceId)/"
    }

    public static func normalizedRootPath(_ rawPath: String) -> String {
        let trimmedPath = rawPath.trimmingCharacters(in: .whitespacesAndNewlines)
        let rootPath = trimmedPath.nonEmpty ?? deviceRootPath(deviceId: nil)
        return rootPath.hasSuffix("/") ? rootPath : "\(rootPath)/"
    }
}

/// Firebase Storage adapter conforming to JetCloudStorageProvider.
public final class JetStorageManager: JetCloudStorageProvider {
    
    // MARK: - Singleton
    
    public static let shared = JetStorageManager()
    
    // MARK: - Properties
    
    private let storage = Storage.storage()
    private let rootPathLock = NSLock()
    private var rootPathProvider: JetStorageRootPathProvider
    
    // MARK: - Initialization
    
    public init(rootPathProvider: JetStorageRootPathProvider = .deviceDefault) {
        self.rootPathProvider = rootPathProvider
    }

    public func configureRootPathProvider(_ provider: JetStorageRootPathProvider) {
        rootPathLock.lock()
        rootPathProvider = provider
        rootPathLock.unlock()
    }

    public func configureRootPathProvider(_ resolveRootPath: @escaping () -> String) {
        configureRootPathProvider(JetStorageRootPathProvider(resolveRootPath))
    }
    
    // MARK: - Upload
    
    /// 把图片上传到当前用户的专属目录：
    /// <JetStorageRootPathProvider.currentRootPath()>/<filename>
    /// - Parameters:
    ///   - image: 要上传的图片
    ///   - filename: 文件名
    ///   - targetKB: 目标压缩大小（KB），默认 100KB
    ///   - completion: 完成回调，返回下载 URL 或错误
    public func uploadImage(
        _ image: UIImage,
        filename: String,
        targetKB: Int = 100,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        // 1️⃣ 压缩图片
        guard let data = image.jet_jpegData(
            targetKB: targetKB,
            minQuality: 0.2,
            initialMaxSide: 1600,
            stepDownRatio: 0.85,
            maxStepDownTimes: 3
        ) else {
            let error = NSError(
                domain: "JetStorageManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to compress image"]
            )
            completion(.failure(error))
            return
        }
        
        // 2️⃣ 决定上传路径：基于宿主 App 注入的云空间根目录
        let fileRef = fileReference(named: filename)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 3️⃣ 上传
        fileRef.putData(data, metadata: metadata) { _, error in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            
            // 4️⃣ 获取下载 URL（如果你只需要存储路径，也可以改成返回 path）
            fileRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url))
                } else {
                    let err = NSError(
                        domain: "JetStorageManager",
                        code: -2,
                        userInfo: [NSLocalizedDescriptionKey: "downloadURL is nil"]
                    )
                    completion(.failure(err))
                }
            }
        }
    }
    
    /// 异步上传图片
    /// - Parameters:
    ///   - image: 要上传的图片
    ///   - filename: 文件名
    ///   - targetKB: 目标压缩大小（KB），默认 100KB
    /// - Returns: 下载 URL
    public func uploadImage(
        _ image: UIImage,
        filename: String,
        targetKB: Int = 100
    ) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            uploadImage(image, filename: filename, targetKB: targetKB) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    // MARK: - List Files
    
    /// 列出当前用户云空间根目录下的所有文件名（仅一层，不递归子目录）
    /// - Returns: 文件名数组
    public func fetchAllImageNames() async throws -> [String] {
        let rootRef = rootReference()
        
        let names: [String] = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String], Error>) in
            rootRef.listAll { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    let names = result.items.map { $0.name }
                    continuation.resume(returning: names)
                } else {
                    let err = NSError(
                        domain: "JetStorageManager",
                        code: -3,
                        userInfo: [NSLocalizedDescriptionKey: "listAll result is nil"]
                    )
                    continuation.resume(throwing: err)
                }
            }
        }
        
        return names
    }
    
    // MARK: - Download
    
    /// 根据文件名从云空间下载图片
    /// - Parameter filename: 文件名
    /// - Returns: 下载的图片
    public func downloadImage(named filename: String) async throws -> UIImage {
        let fileRef = fileReference(named: filename)
        
        // 最大 20MB
        let maxSize: Int64 = 20 * 1024 * 1024
        
        let data: Data = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
            fileRef.getData(maxSize: maxSize) { data, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    let err = NSError(
                        domain: "JetStorageManager",
                        code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "download data is nil"]
                    )
                    continuation.resume(throwing: err)
                }
            }
        }
        
        guard let image = UIImage(data: data) else {
            throw NSError(
                domain: "JetStorageManager",
                code: -5,
                userInfo: [NSLocalizedDescriptionKey: "Failed to decode image from data"]
            )
        }
        return image
    }
    
    // MARK: - Delete
    
    /// 删除指定文件
    /// - Parameter filename: 文件名
    public func deleteImage(named filename: String) async throws {
        let fileRef = fileReference(named: filename)
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            fileRef.delete { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    // MARK: - Storage Info
    
    /// 获取文件的元数据
    /// - Parameter filename: 文件名
    /// - Returns: 文件元数据
    public func getMetadata(for filename: String) async throws -> StorageMetadata {
        let fileRef = fileReference(named: filename)
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<StorageMetadata, Error>) in
            fileRef.getMetadata { metadata, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let metadata = metadata {
                    continuation.resume(returning: metadata)
                } else {
                    let err = NSError(
                        domain: "JetStorageManager",
                        code: -6,
                        userInfo: [NSLocalizedDescriptionKey: "getMetadata result is nil"]
                    )
                    continuation.resume(throwing: err)
                }
            }
        }
    }
    
    /// 获取文件的下载 URL
    /// - Parameter filename: 文件名
    /// - Returns: 下载 URL
    public func getDownloadURL(for filename: String) async throws -> URL {
        let fileRef = fileReference(named: filename)
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            fileRef.downloadURL { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    continuation.resume(returning: url)
                } else {
                    let err = NSError(
                        domain: "JetStorageManager",
                        code: -7,
                        userInfo: [NSLocalizedDescriptionKey: "downloadURL is nil"]
                    )
                    continuation.resume(throwing: err)
                }
            }
        }
    }
}

private extension JetStorageManager {
    func currentRootPath() -> String {
        rootPathLock.lock()
        let provider = rootPathProvider
        rootPathLock.unlock()
        return provider.currentRootPath()
    }

    func rootReference() -> StorageReference {
        storage.reference().child(currentRootPath())
    }

    func fileReference(named filename: String) -> StorageReference {
        rootReference().child(filename)
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
