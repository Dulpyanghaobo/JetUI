//
//  JetCloudStorageProtocol.swift
//  JetUI
//
//  Platform-agnostic cloud-storage protocol.
//  JetUI modules depend on this; FirebaseStorage is one swappable backend.
//

#if canImport(UIKit)
import UIKit

// MARK: - Protocol

/// Implement this protocol to plug any cloud-storage backend into JetUI.
public protocol JetCloudStorageProvider: AnyObject {
    /// Upload a UIImage; returns the remote download URL.
    func uploadImage(_ image: UIImage, filename: String, targetKB: Int) async throws -> URL

    /// Download an image by filename.
    func downloadImage(named filename: String) async throws -> UIImage

    /// List all file names in the current user's root directory.
    func fetchAllImageNames() async throws -> [String]

    /// Delete a file by filename.
    func deleteImage(named filename: String) async throws

    /// Get the public download URL for a filename.
    func getDownloadURL(for filename: String) async throws -> URL
}

// MARK: - Registry

/// Central storage registry used by JetUI modules.
public final class JetCloudStorage {

    public static let shared = JetCloudStorage()

    private var provider: JetCloudStorageProvider?

    private init() {}

    /// Register the active backend (typically called at app startup).
    public func register(_ provider: JetCloudStorageProvider) {
        self.provider = provider
    }

    // MARK: Forwarding helpers

    public func uploadImage(_ image: UIImage, filename: String, targetKB: Int = 100) async throws -> URL {
        guard let p = provider else { throw JetCloudStorageError.notConfigured }
        return try await p.uploadImage(image, filename: filename, targetKB: targetKB)
    }

    public func downloadImage(named filename: String) async throws -> UIImage {
        guard let p = provider else { throw JetCloudStorageError.notConfigured }
        return try await p.downloadImage(named: filename)
    }

    public func fetchAllImageNames() async throws -> [String] {
        guard let p = provider else { throw JetCloudStorageError.notConfigured }
        return try await p.fetchAllImageNames()
    }

    public func deleteImage(named filename: String) async throws {
        guard let p = provider else { throw JetCloudStorageError.notConfigured }
        try await p.deleteImage(named: filename)
    }

    public func getDownloadURL(for filename: String) async throws -> URL {
        guard let p = provider else { throw JetCloudStorageError.notConfigured }
        return try await p.getDownloadURL(for: filename)
    }
}

// MARK: - Error

public enum JetCloudStorageError: Error, LocalizedError {
    case notConfigured

    public var errorDescription: String? {
        "JetCloudStorage: no provider registered. Call JetCloudStorage.shared.register(_:) at startup."
    }
}
#endif
