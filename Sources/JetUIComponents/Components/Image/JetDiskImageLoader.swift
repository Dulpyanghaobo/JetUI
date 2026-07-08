//
//  JetDiskImageLoader.swift
//  JetUI
//
//  Disk-backed image loader for reusable async image components.
//

import UIKit

public final class JetDiskImageLoader: JetImageLoader, @unchecked Sendable {
    public static let shared = JetDiskImageLoader()

    private let memoryCache = NSCache<NSURL, UIImage>()
    private let diskCacheDirectory: URL
    private let session: URLSession
    private let fileManager: FileManager
    private let lock = NSLock()
    private var downloadTasks: [URL: URLSessionDataTask] = [:]

    public var cacheSizeLimit: Int {
        get { memoryCache.totalCostLimit }
        set { memoryCache.totalCostLimit = newValue }
    }

    public init(
        diskCacheDirectory: URL? = nil,
        session: URLSession? = nil,
        fileManager: FileManager = .default,
        memoryCountLimit: Int = 100,
        memoryCostLimit: Int = 100 * 1024 * 1024
    ) {
        self.fileManager = fileManager

        if let diskCacheDirectory {
            self.diskCacheDirectory = diskCacheDirectory
        } else {
            let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
            self.diskCacheDirectory = cacheDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        }

        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.requestCachePolicy = .returnCacheDataElseLoad
            configuration.urlCache = URLCache(
                memoryCapacity: 50 * 1024 * 1024,
                diskCapacity: 200 * 1024 * 1024,
                diskPath: "ImageDownloadCache"
            )
            self.session = URLSession(configuration: configuration)
        }

        memoryCache.countLimit = memoryCountLimit
        memoryCache.totalCostLimit = memoryCostLimit
        try? fileManager.createDirectory(at: self.diskCacheDirectory, withIntermediateDirectories: true)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func load(url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cached = memoryCache.object(forKey: url as NSURL) {
            completion(cached)
            return
        }

        if let diskCached = loadFromDisk(url: url) {
            memoryCache.setObject(diskCached, forKey: url as NSURL, cost: cost(of: diskCached))
            completion(diskCached)
            return
        }

        downloadImage(url: url, completion: completion)
    }

    public func setImage(_ image: UIImage, forKey key: URL) {
        memoryCache.setObject(image, forKey: key as NSURL, cost: cost(of: image))
        saveToDisk(image: image, url: key)
    }

    public func getImage(forKey key: URL) -> UIImage? {
        if let cached = memoryCache.object(forKey: key as NSURL) {
            return cached
        }

        if let diskCached = loadFromDisk(url: key) {
            memoryCache.setObject(diskCached, forKey: key as NSURL, cost: cost(of: diskCached))
            return diskCached
        }

        return nil
    }

    public func cleanExpiredCache() {
        memoryCache.removeAllObjects()
        let cutoffDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        clearCache(olderThan: cutoffDate)
    }

    public func clearCache(olderThan date: Date) {
        guard let enumerator = fileManager.enumerator(
            at: diskCacheDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        while let fileURL = enumerator.nextObject() as? URL {
            guard
                let values = try? fileURL.resourceValues(forKeys: [.contentModificationDateKey]),
                let modificationDate = values.contentModificationDate,
                modificationDate < date
            else {
                continue
            }
            try? fileManager.removeItem(at: fileURL)
        }
    }

    public func clearAllCache() {
        memoryCache.removeAllObjects()
        try? fileManager.removeItem(at: diskCacheDirectory)
        try? fileManager.createDirectory(at: diskCacheDirectory, withIntermediateDirectories: true)
    }

    public func cancelDownload(for url: URL) {
        lock.lock()
        let task = downloadTasks.removeValue(forKey: url)
        lock.unlock()

        task?.cancel()
    }

    public func loadAsync(url: URL) async -> UIImage? {
        await withCheckedContinuation { continuation in
            load(url: url) { image in
                continuation.resume(returning: image)
            }
        }
    }

    private func downloadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        lock.lock()
        if downloadTasks[url] != nil {
            lock.unlock()
            return
        }

        let task = session.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }

            self.lock.lock()
            self.downloadTasks.removeValue(forKey: url)
            self.lock.unlock()

            guard
                error == nil,
                let data,
                let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            self.memoryCache.setObject(image, forKey: url as NSURL, cost: data.count)
            self.saveToDisk(data: data, url: url)

            DispatchQueue.main.async {
                completion(image)
            }
        }

        downloadTasks[url] = task
        lock.unlock()
        task.resume()
    }

    private func cacheFilePath(for url: URL) -> URL {
        let fileName = url.absoluteString
            .data(using: .utf8)?
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-") ?? UUID().uuidString
        return diskCacheDirectory.appendingPathComponent(fileName)
    }

    private func saveToDisk(image: UIImage, url: URL) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            saveToDisk(data: data, url: url)
        } else if let data = image.pngData() {
            saveToDisk(data: data, url: url)
        }
    }

    private func saveToDisk(data: Data, url: URL) {
        let filePath = cacheFilePath(for: url)
        try? data.write(to: filePath)
    }

    private func loadFromDisk(url: URL) -> UIImage? {
        let filePath = cacheFilePath(for: url)
        guard
            fileManager.fileExists(atPath: filePath.path),
            let data = try? Data(contentsOf: filePath),
            let image = UIImage(data: data)
        else {
            return nil
        }
        return image
    }

    private func cost(of image: UIImage) -> Int {
        image.jpegData(compressionQuality: 1.0)?.count ?? 0
    }

    @objc private func handleMemoryWarning() {
        memoryCache.removeAllObjects()
    }
}
