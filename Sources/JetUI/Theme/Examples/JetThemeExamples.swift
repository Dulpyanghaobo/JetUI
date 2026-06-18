//
//  JetThemeExamples.swift
//  JetUI
//
//  Example theme presets for testing and previewing JetUI theme injection.
//

import SwiftUI

// MARK: - Example Custom Color Palette

public struct ExampleColorPalette: JetColorPalette {
    public init() {}

    public var brandPrimary: Color { Color(red: 0.40, green: 0.20, blue: 0.90) }
    public var brandSecondary: Color { Color(red: 0.15, green: 0.08, blue: 0.35) }

    public var backgroundPrimary: Color { Color(red: 0.07, green: 0.07, blue: 0.10) }
    public var backgroundSecondary: Color { Color(red: 0.12, green: 0.12, blue: 0.16) }
    public var backgroundTertiary: Color { Color(red: 0.16, green: 0.16, blue: 0.20) }

    public var textPrimary: Color { .white }
    public var textSecondary: Color { Color(white: 0.75) }
    public var textTertiary: Color { Color(white: 0.55) }
    public var textDisabled: Color { Color(white: 0.35) }

    public var success: Color { Color(red: 0.20, green: 0.82, blue: 0.50) }
    public var warning: Color { Color(red: 1.00, green: 0.80, blue: 0.00) }
    public var error: Color { Color(red: 0.95, green: 0.27, blue: 0.27) }

    public var gray900: Color { Color(white: 0.10) }
    public var gray800: Color { Color(white: 0.15) }
    public var gray700: Color { Color(white: 0.30) }
    public var gray500: Color { Color(white: 0.55) }
    public var gray300: Color { Color(white: 0.75) }
    public var gray100: Color { Color(white: 0.90) }

    public var proGold: Color { Color(red: 1.00, green: 0.76, blue: 0.15) }
    public var goldAccent: Color { Color(red: 1.00, green: 0.84, blue: 0.00) }
    public var goldDark: Color { Color(red: 0.86, green: 0.58, blue: 0.00) }
    public var orangeAccent: Color { Color(red: 1.00, green: 0.42, blue: 0.00) }

    public var accentBlue: Color { Color(red: 0.29, green: 0.56, blue: 0.89) }
    public var growthGreen: Color { Color(red: 0.31, green: 0.78, blue: 0.47) }

    public var premiumPurple: Color { Color(red: 0.54, green: 0.36, blue: 0.96) }
    public var linkBlue: Color { Color(red: 0.23, green: 0.51, blue: 0.96) }

    public var cardDark: Color { Color(red: 0.11, green: 0.11, blue: 0.14) }
    public var surfaceLight: Color { Color(red: 0.18, green: 0.18, blue: 0.22) }
    public var surfaceDark: Color { Color(red: 0.08, green: 0.08, blue: 0.10) }

    public var pointsYellow: Color { Color(red: 0.98, green: 0.75, blue: 0.14) }
    public var mintGreen: Color { Color(red: 0.06, green: 0.72, blue: 0.51) }
}

// MARK: - Example System-Font Typography

public struct ExampleSystemTypography: JetTypography {
    public init() {}

    public var displayXXL: Font { .system(size: 70, weight: .black, design: .rounded) }
    public var displayXL: Font { .system(size: 34, weight: .bold, design: .rounded) }
    public var displayL: Font { .system(size: 32, weight: .bold, design: .rounded) }

    public var headingL: Font { .system(size: 20, weight: .bold) }
    public var headingM: Font { .system(size: 24, weight: .bold) }
    public var headingS: Font { .system(size: 16, weight: .semibold) }

    public var bodyL: Font { .system(size: 16, weight: .regular) }
    public var bodyM1: Font { .system(size: 18, weight: .medium) }
    public var bodyM: Font { .system(size: 16, weight: .medium) }
    public var bodyS: Font { .system(size: 14, weight: .medium) }

    public var caption: Font { .system(size: 12, weight: .medium) }
    public var footnote: Font { .system(size: 12, weight: .regular) }
    public var footnote2: Font { .system(size: 14, weight: .regular) }
}

// MARK: - Example Theme (purple-branded, system fonts)

public struct ExampleTheme: JetThemeConfig {
    public init() {}
    public var colors: JetColorPalette { ExampleColorPalette() }
    public var fonts: JetTypography { ExampleSystemTypography() }
    public var layout: JetLayoutConfig { DefaultLayoutConfig() }
}
