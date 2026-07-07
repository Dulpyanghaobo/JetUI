//
//  JetCacheAsyncImage.swift
//  JetUI
//
//  Async image view with caching support via protocol injection
//

import SwiftUI

// MARK: - Image Loader Protocol

/// Protocol for image loading with caching
public protocol JetImageLoader {
    /// Load image from URL
    /// - Parameters:
    ///   - url: Image URL
    ///   - completion: Completion handler with optional UIImage
    func load(url: URL, completion: @escaping (UIImage?) -> Void)
}

// MARK: - Cache Async Image View

/// Async image view with caching support
public struct JetCacheAsyncImage: View {
    
    // MARK: - Properties
    
    let url: URL?
    let imageLoader: JetImageLoader
    let placeholder: Color
    let contentMode: ContentMode
    
    @State private var image: UIImage?
    
    // MARK: - Initializer
    
    /// Create a cached async image view
    /// - Parameters:
    ///   - url: Image URL
    ///   - imageLoader: Image loader implementation
    ///   - placeholder: Placeholder color while loading
    ///   - contentMode: Content mode for the image
    public init(
        url: URL?,
        imageLoader: JetImageLoader,
        placeholder: Color = Color.white.opacity(0.08),
        contentMode: ContentMode = .fill
    ) {
        self.url = url
        self.imageLoader = imageLoader
        self.placeholder = placeholder
        self.contentMode = contentMode
    }
    
    // MARK: - Body
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Placeholder background
                placeholder
                
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                } else {
                    ProgressView()
                        .tint(.white.opacity(0.6))
                        .onAppear { loadImage() }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
    
    // MARK: - Private Methods
    
    private func loadImage() {
        guard let url else { return }
        imageLoader.load(url: url) { img in
            DispatchQueue.main.async {
                self.image = img
            }
        }
    }
}

// MARK: - Default Image Loader

/// Default image loader using URLSession
public final class JetDefaultImageLoader: JetImageLoader {
    
    public static let shared = JetDefaultImageLoader()
    
    private let cache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = 100
    }
    
    public func load(url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cached = cache.object(forKey: url as NSURL) {
            completion(cached)
            return
        }
        
        // Download image
        session.dataTask(with: url) { [weak self] data, _, error in
            guard error == nil,
                  let data = data,
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            // Cache the image
            self?.cache.setObject(image, forKey: url as NSURL)
            completion(image)
        }.resume()
    }
    
    /// Clear all cached images
    public func clearCache() {
        cache.removeAllObjects()
    }
}

// MARK: - Convenience Extensions

public extension JetCacheAsyncImage {
    
    /// Create with default image loader
    /// - Parameters:
    ///   - url: Image URL
    ///   - placeholder: Placeholder color
    ///   - contentMode: Content mode
    init(
        url: URL?,
        placeholder: Color = Color.white.opacity(0.08),
        contentMode: ContentMode = .fill
    ) {
        self.init(
            url: url,
            imageLoader: JetDefaultImageLoader.shared,
            placeholder: placeholder,
            contentMode: contentMode
        )
    }
}

// MARK: - URL String Convenience

public extension JetCacheAsyncImage {
    
    /// Create from URL string
    /// - Parameters:
    ///   - urlString: Image URL string
    ///   - imageLoader: Image loader implementation
    ///   - placeholder: Placeholder color
    ///   - contentMode: Content mode
    init(
        urlString: String?,
        imageLoader: JetImageLoader,
        placeholder: Color = Color.white.opacity(0.08),
        contentMode: ContentMode = .fill
    ) {
        let url = urlString.flatMap { URL(string: $0) }
        self.init(
            url: url,
            imageLoader: imageLoader,
            placeholder: placeholder,
            contentMode: contentMode
        )
    }
}