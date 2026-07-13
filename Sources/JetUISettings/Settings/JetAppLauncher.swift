//
//  JetAppLauncher.swift
//  JetUI
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

/// A stable identity for a Jet product.
///
/// Hosts declare their own current value and pass it to `recommendations(excluding:)`,
/// so the shared package never relies on mutable global app state.
public enum JetProduct: String, CaseIterable, Hashable, Identifiable, Sendable {
    case jetScan
    case timeStamp
    case timeProof
    case jetFax

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .jetScan: "JetScan"
        case .timeStamp: "TimeStamp"
        case .timeProof: "TimeProof"
        case .jetFax: "JetFax"
        }
    }
}

/// Opens a companion app when its deep link is available and falls back to its
/// App Store URL when it is not installed.
public enum JetAppLauncher {
    /// Returns the configured cross-promotion item for a known Jet product.
    ///
    /// `JetScan` is the current DocumentScan product identity. It intentionally
    /// has no external launch target until its own deep link and App Store URL
    /// are registered in the shared catalog.
    public static func item(for product: JetProduct) -> JetAppItem? {
        JetAppItem.companyApps.first { $0.product == product }
    }

    /// Builds the companion-app list for a host product, omitting that host from
    /// its own recommendations.
    public static func recommendations(excluding currentProduct: JetProduct?) -> [JetAppItem] {
        JetAppItem.companyApps.filter { $0.product != currentProduct }
    }

    /// Launches a known product when it has a configured companion-app target.
    /// Returns `false` when the product has no external launch target configured.
    @discardableResult
    public static func open(product: JetProduct) -> Bool {
        guard let item = item(for: product) else { return false }
        open(item)
        return true
    }

    /// Launches a recommendation item using its primary and fallback URLs.
    public static func open(_ item: JetAppItem) {
        open(primaryURL: item.actionURL, fallbackURL: item.fallbackURL)
    }

    /// Opens `primaryURL`, then opens `fallbackURL` if the system cannot handle
    /// the primary URL. Use this for any cross-promotion or companion-app entry.
    public static func open(primaryURL: URL, fallbackURL: URL? = nil) {
        #if canImport(UIKit)
        UIApplication.shared.open(primaryURL, options: [:]) { succeeded in
            guard !succeeded, let fallbackURL else { return }
            UIApplication.shared.open(fallbackURL, options: [:], completionHandler: nil)
        }
        #endif
    }
}
