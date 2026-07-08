//
//  JetReviewPrompter.swift
//  JetUI
//
//  Store review prompt throttling shared by product apps.
//

import Foundation

#if canImport(UIKit)
import StoreKit
import UIKit
#endif

public final class JetReviewPrompter {
    public static let shared = JetReviewPrompter()

    public static let launchCountKey = "review.launch.count"
    public static let photoSaveCountKey = "review.photo.save.count"
    public static let lastPromptDateKey = "review.last.prompt.date"

    private let store: UserDefaults
    private let clock: () -> Date
    private let requestReview: () -> Bool
    private let photoSaveThreshold: Int

    public init(
        store: UserDefaults = .standard,
        clock: @escaping () -> Date = Date.init,
        photoSaveThreshold: Int = 3,
        requestReview: @escaping () -> Bool = JetReviewPrompter.requestSystemReview
    ) {
        self.store = store
        self.clock = clock
        self.photoSaveThreshold = photoSaveThreshold
        self.requestReview = requestReview
    }

    public func appLaunched() {
        let count = store.integer(forKey: Self.launchCountKey) + 1
        store.set(count, forKey: Self.launchCountKey)
    }

    public func photoSaved() {
        let count = store.integer(forKey: Self.photoSaveCountKey) + 1
        store.set(count, forKey: Self.photoSaveCountKey)

        if count >= photoSaveThreshold {
            requestIfAllowed()
        }
    }

    @discardableResult
    public func requestIfAllowed(cooldownDays: Int = 7) -> Bool {
        if let lastPromptDate = store.object(forKey: Self.lastPromptDateKey) as? Date {
            let cooldown = Double(cooldownDays) * 24 * 60 * 60
            if clock().timeIntervalSince(lastPromptDate) < cooldown {
                return false
            }
        }

        guard requestReview() else {
            return false
        }

        store.set(clock(), forKey: Self.lastPromptDateKey)
        store.set(0, forKey: Self.photoSaveCountKey)
        return true
    }

    public func resetCounters() {
        store.removeObject(forKey: Self.launchCountKey)
        store.removeObject(forKey: Self.photoSaveCountKey)
        store.removeObject(forKey: Self.lastPromptDateKey)
    }

    public static func requestSystemReview() -> Bool {
        #if canImport(UIKit) && !os(watchOS)
        let request: () -> Bool = {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return false
            }
            SKStoreReviewController.requestReview(in: scene)
            return true
        }

        if Thread.isMainThread {
            return request()
        }

        DispatchQueue.main.async {
            _ = request()
        }
        return true
        #else
        return false
        #endif
    }
}
