//
//  JetSubscriptionRegistry.swift
//  JetUI
//
//  Shared subscription registry used by subscription modules and the JetUI facade.
//

import Foundation

public enum JetSubscriptionRegistry {
    public private(set) static var config: JetSubscriptionConfig?
    public private(set) static var runtime: JetSubscriptionRuntime?
    public private(set) static var manager: JetSubscriptionManager?
    public static var paywallConfiguration: JetPaywallConfiguration?

    @MainActor
    public static func configure(runtime: JetSubscriptionRuntime) {
        config = runtime.config
        self.runtime = runtime
        manager = runtime.manager
    }

    public static func reset() {
        config = nil
        runtime = nil
        manager = nil
        paywallConfiguration = nil
    }
}
