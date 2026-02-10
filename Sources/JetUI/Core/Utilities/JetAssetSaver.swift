//
//  JetAssetSaver.swift
//  JetUI
//
//  Image asset saving utilities
//

import UIKit

/// Asset saving utility for images
public enum JetAssetSaver {
    
    /// Save UIImage as JPEG to documents directory
    /// - Parameters:
    ///   - image: UIImage to save
    ///   - quality: JPEG compression quality (0.0 to 1.0)
    /// - Returns: URL of saved file
    /// - Throws: CocoaError if saving fails
    public static func saveJPEG(_ image: UIImage, quality: CGFloat = 0.95) throws -> URL {
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw CocoaError(.fileWriteUnknown)
        }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = dir.appendingPathComponent("\(UUID().uuidString).jpg")
        try data.write(to: url, options: .atomic)
        return url
    }
    
    /// Save UIImage as PNG to documents directory
    /// - Parameter image: UIImage to save
    /// - Returns: URL of saved file
    /// - Throws: CocoaError if saving fails
    public static func savePNG(_ image: UIImage) throws -> URL {
        guard let data = image.pngData() else {
            throw CocoaError(.fileWriteUnknown)
        }
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let url = dir.appendingPathComponent("\(UUID().uuidString).png")
        try data.write(to: url, options: .atomic)
        return url
    }
    
    /// Save UIImage to custom directory
    /// - Parameters:
    ///   - image: UIImage to save
    ///   - directory: Target directory URL
    ///   - filename: Optional filename (default: UUID)
    ///   - format: Image format (.jpeg or .png)
    ///   - quality: JPEG quality (only used for .jpeg format)
    /// - Returns: URL of saved file
    /// - Throws: CocoaError if saving fails
    public static func save(
        _ image: UIImage,
        to directory: URL,
        filename: String? = nil,
        format: ImageFormat = .jpeg,
        quality: CGFloat = 0.95
    ) throws -> URL {
        let data: Data
        let ext: String
        
        switch format {
        case .jpeg:
            guard let jpegData = image.jpegData(compressionQuality: quality) else {
                throw CocoaError(.fileWriteUnknown)
            }
            data = jpegData
            ext = "jpg"
        case .png:
            guard let pngData = image.pngData() else {
                throw CocoaError(.fileWriteUnknown)
            }
            data = pngData
            ext = "png"
        }
        
        let name = filename ?? UUID().uuidString
        let url = directory.appendingPathComponent("\(name).\(ext)")
        
        // Create directory if needed
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        
        try data.write(to: url, options: .atomic)
        return url
    }
    
    /// Save UIImage to temporary directory
    /// - Parameters:
    ///   - image: UIImage to save
    ///   - format: Image format
    ///   - quality: JPEG quality
    /// - Returns: URL of saved file
    /// - Throws: CocoaError if saving fails
    public static func saveToTemp(
        _ image: UIImage,
        format: ImageFormat = .jpeg,
        quality: CGFloat = 0.95
    ) throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        return try save(image, to: tempDir, format: format, quality: quality)
    }
    
    /// Delete file at URL
    /// - Parameter url: File URL to delete
    /// - Throws: Error if deletion fails
    public static func delete(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}

// MARK: - Image Format

public extension JetAssetSaver {
    
    /// Supported image formats
    enum ImageFormat {
        case jpeg
        case png
    }
}

// MARK: - Backward Compatibility

/// Backward compatibility alias
public typealias AssetSaver = JetAssetSaver