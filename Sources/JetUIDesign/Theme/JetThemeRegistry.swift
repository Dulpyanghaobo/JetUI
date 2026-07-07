//
//  JetThemeRegistry.swift
//  JetUI
//
//  Shared theme registry used by design tokens and the JetUI compatibility facade.
//

import Foundation

public enum JetThemeRegistry {
    public private(set) static var theme: JetThemeConfig = DefaultTheme()

    public static func configure(_ config: JetThemeConfig) {
        theme = config
    }
}
