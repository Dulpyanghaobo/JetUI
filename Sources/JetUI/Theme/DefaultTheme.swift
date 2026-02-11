//
//  DefaultTheme.swift
//  JetUI
//
//  Default theme implementation using the exact values from the original AppColor and AppFont.
//  This ensures backward compatibility - the library looks the same by default.
//

import SwiftUI

// MARK: - Default Color Palette

/// Default color implementation using the original hardcoded hex values
public struct DefaultColorPalette: JetColorPalette {
    
    public init() {}
    
    // MARK: Brand Colors
    public var brandPrimary: Color { Color(hex: 0x2786D5) }      // Original: themeColor
    public var brandSecondary: Color { Color(hex: 0x071F4C) }    // Original: subscripBackColor
    
    // MARK: Background Colors
    public var backgroundPrimary: Color { Color(hex: 0x161615) } // Original: primaryBackground
    public var backgroundSecondary: Color { Color(hex: 0x212121) } // Original: primary700
    public var backgroundTertiary: Color { Color(hex: 0x252525) } // Original: gray901
    
    // MARK: Text Colors
    public var textPrimary: Color { Color(hex: 0x1A1A1A) }       // Original: gray900
    public var textSecondary: Color { Color(hex: 0x4D4D4D) }     // Original: gray700
    public var textTertiary: Color { Color(hex: 0x8C8C8C) }      // Original: gray500
    public var textDisabled: Color { Color(hex: 0xD9D9D9) }      // Original: gray300
    
    // MARK: Semantic Colors
    public var success: Color { Color(hex: 0x1FAD66) }
    public var warning: Color { Color(hex: 0xFFCC00) }
    public var error: Color { Color(hex: 0xF24822) }
    
    // MARK: Gray Scale (Raw Palette)
    public var gray900: Color { Color(hex: 0x1A1A1A) }
    public var gray800: Color { Color(hex: 0x252525) }           // gray901
    public var gray700: Color { Color(hex: 0x4D4D4D) }
    public var gray500: Color { Color(hex: 0x8C8C8C) }
    public var gray300: Color { Color(hex: 0xD9D9D9) }
    public var gray100: Color { Color(hex: 0x757575) }
    
    // MARK: Extended Colors (App-specific defaults)
    public var proGold: Color { Color(hex: 0xFFA800) }           // Pro/Premium gold
    public var goldAccent: Color { Color(hex: 0xFFD700) }        // Gold accent
    public var goldDark: Color { Color(hex: 0xDB9300) }          // Dark gold
    public var orangeAccent: Color { Color(hex: 0xFF6B00) }      // Orange accent
    
    public var accentBlue: Color { Color(hex: 0x4A90E2) }        // XP/Progress blue
    public var growthGreen: Color { Color(hex: 0x50C878) }       // Growth/Success green
    
    public var premiumPurple: Color { Color(hex: 0x8B5CF6) }     // Premium purple
    public var linkBlue: Color { Color(hex: 0x3B82F6) }          // Link blue
    
    public var cardDark: Color { Color(hex: 0x1C1C1E) }          // Dark card background
    public var surfaceLight: Color { Color(hex: 0x2A2A2A) }      // Light surface
    public var surfaceDark: Color { Color(hex: 0x151515) }       // Dark surface
    
    public var pointsYellow: Color { Color(hex: 0xFBBF24) }      // Points yellow
    public var mintGreen: Color { Color(hex: 0x10B981) }         // Mint green
}

// MARK: - Default Typography

/// Default typography implementation using Quicksand font family
public struct DefaultTypography: JetTypography {
    
    public init() {}
    
    // MARK: Display (Hero Text)
    public var displayXXL: Font { .custom("Quicksand-Bold", size: 70, relativeTo: .largeTitle) }
    public var displayXL: Font { .custom("Quicksand-Bold", size: 34, relativeTo: .largeTitle) }
    public var displayL: Font { .custom("Quicksand-Bold", size: 32, relativeTo: .title) }
    
    // MARK: Headings
    public var headingL: Font { .custom("Quicksand-Bold", size: 20, relativeTo: .title3) }
    public var headingM: Font { .custom("Quicksand-Bold", size: 24, relativeTo: .title2) }
    public var headingS: Font { .custom("Quicksand-Bold", size: 16, relativeTo: .title3) }
    
    // MARK: Body Text
    public var bodyL: Font { .custom("Quicksand-Regular", size: 16, relativeTo: .body) }
    public var bodyM1: Font { .custom("Quicksand-Medium", size: 18, relativeTo: .subheadline) }
    public var bodyM: Font { .custom("Quicksand-Medium", size: 16, relativeTo: .subheadline) }
    public var bodyS: Font { .custom("Quicksand-Medium", size: 14, relativeTo: .callout) }
    
    // MARK: Utility Text
    public var caption: Font { .custom("Quicksand-Medium", size: 12, relativeTo: .caption) }
    public var footnote: Font { .custom("Quicksand-Regular", size: 12, relativeTo: .footnote) }
    public var footnote2: Font { .custom("Quicksand-Regular", size: 14, relativeTo: .footnote) }
}

// MARK: - Default Spacing

/// Default spacing values following 4pt grid system
public struct DefaultSpacing: JetSpacing {
    
    public init() {}
    
    public var xs: CGFloat { 4 }
    public var s: CGFloat { 8 }
    public var m: CGFloat { 16 }
    public var l: CGFloat { 24 }
    public var xl: CGFloat { 32 }
    public var xxl: CGFloat { 48 }
}

// MARK: - Default Radius

/// Default corner radius values
public struct DefaultRadius: JetRadius {
    
    public init() {}
    
    public var small: CGFloat { 4 }
    public var medium: CGFloat { 8 }
    public var large: CGFloat { 16 }
    public var extraLarge: CGFloat { 24 }
    public var pill: CGFloat { 999 }
}

// MARK: - Default Icons

/// Default icons using SF Symbols
public struct DefaultIcons: JetIcons {
    
    public init() {}
    
    public var backArrow: Image { Image(systemName: "chevron.left") }
    public var close: Image { Image(systemName: "xmark") }
    public var checkmark: Image { Image(systemName: "checkmark") }
    public var chevronRight: Image { Image(systemName: "chevron.right") }
    public var chevronDown: Image { Image(systemName: "chevron.down") }
    public var settings: Image { Image(systemName: "gearshape") }
    public var search: Image { Image(systemName: "magnifyingglass") }
}

// MARK: - Default Layout Config

/// Default layout configuration containing spacing, radius, and icons
public struct DefaultLayoutConfig: JetLayoutConfig {
    
    public init() {}
    
    public var spacing: JetSpacing { DefaultSpacing() }
    public var radius: JetRadius { DefaultRadius() }
    public var icons: JetIcons { DefaultIcons() }
}

// MARK: - Default Theme

/// Default theme implementation - ensures backward compatibility
/// Uses the exact values from the original AppColor and AppFont files
public struct DefaultTheme: JetThemeConfig {
    
    public init() {}
    
    public var colors: JetColorPalette { DefaultColorPalette() }
    public var fonts: JetTypography { DefaultTypography() }
    public var layout: JetLayoutConfig { DefaultLayoutConfig() }
}