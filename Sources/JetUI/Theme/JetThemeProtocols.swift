//
//  JetThemeProtocols.swift
//  JetUI
//
//  Theme system protocols for dependency injection.
//  The library defines semantics (interfaces), host apps inject implementations (values).
//

import SwiftUI

// MARK: - 1. Color Palette Protocol

/// Semantic color protocol - defines what colors an app needs, not the actual values
public protocol JetColorPalette {
    
    // MARK: Brand Colors
    /// Primary brand color (e.g., theme color, accent)
    var brandPrimary: Color { get }
    /// Secondary brand color (e.g., subscription background)
    var brandSecondary: Color { get }
    
    // MARK: Background Colors
    /// Primary background (main screen background)
    var backgroundPrimary: Color { get }
    /// Secondary background (cards, sections)
    var backgroundSecondary: Color { get }
    /// Tertiary background (modals, popups)
    var backgroundTertiary: Color { get }
    
    // MARK: Text Colors
    /// Primary text color (headings, important text)
    var textPrimary: Color { get }
    /// Secondary text color (body text, descriptions)
    var textSecondary: Color { get }
    /// Tertiary text color (placeholders, hints)
    var textTertiary: Color { get }
    /// Disabled text color
    var textDisabled: Color { get }
    
    // MARK: Semantic Colors
    /// Success state color
    var success: Color { get }
    /// Warning state color
    var warning: Color { get }
    /// Error state color
    var error: Color { get }
    
    // MARK: Gray Scale (Raw Palette)
    /// Darkest gray (near black)
    var gray900: Color { get }
    /// Very dark gray
    var gray800: Color { get }
    /// Dark gray
    var gray700: Color { get }
    /// Medium gray
    var gray500: Color { get }
    /// Light gray
    var gray300: Color { get }
    /// Very light gray
    var gray100: Color { get }
}

// MARK: - 2. Typography Protocol

/// Semantic typography protocol - defines text styles
public protocol JetTypography {
    
    // MARK: Display (Hero Text)
    /// Extra extra large display (e.g., 70pt hero text)
    var displayXXL: Font { get }
    /// Extra large display (e.g., 34pt large title)
    var displayXL: Font { get }
    /// Large display (e.g., 32pt title)
    var displayL: Font { get }
    
    // MARK: Headings
    /// Large heading (e.g., 20pt)
    var headingL: Font { get }
    /// Medium heading (e.g., 24pt)
    var headingM: Font { get }
    /// Small heading (e.g., 16pt)
    var headingS: Font { get }
    
    // MARK: Body Text
    /// Large body text (e.g., 16pt regular)
    var bodyL: Font { get }
    /// Medium body text variant 1 (e.g., 18pt medium)
    var bodyM1: Font { get }
    /// Medium body text (e.g., 16pt medium)
    var bodyM: Font { get }
    /// Small body text (e.g., 14pt)
    var bodyS: Font { get }
    
    // MARK: Utility Text
    /// Caption text (e.g., 12pt for labels)
    var caption: Font { get }
    /// Footnote text (e.g., 12pt for fine print)
    var footnote: Font { get }
    /// Footnote variant 2 (e.g., 14pt)
    var footnote2: Font { get }
}

// MARK: - 3. Spacing Protocol

/// Semantic spacing values for consistent layout
public protocol JetSpacing {
    /// Extra small spacing (e.g., 4pt)
    var xs: CGFloat { get }
    /// Small spacing (e.g., 8pt)
    var s: CGFloat { get }
    /// Medium spacing - standard (e.g., 16pt)
    var m: CGFloat { get }
    /// Large spacing (e.g., 24pt)
    var l: CGFloat { get }
    /// Extra large spacing (e.g., 32pt)
    var xl: CGFloat { get }
    /// Extra extra large spacing (e.g., 48pt)
    var xxl: CGFloat { get }
}

// MARK: - 4. Corner Radius Protocol

/// Semantic corner radius values
public protocol JetRadius {
    /// Small radius (e.g., 4pt for small elements)
    var small: CGFloat { get }
    /// Medium radius (e.g., 8pt for cards)
    var medium: CGFloat { get }
    /// Large radius (e.g., 16pt for modals)
    var large: CGFloat { get }
    /// Extra large radius (e.g., 24pt)
    var extraLarge: CGFloat { get }
    /// Pill radius (e.g., 999pt for capsule buttons)
    var pill: CGFloat { get }
}

// MARK: - 5. Icons Protocol (Optional)

/// Semantic icons - allows apps to customize standard icons
public protocol JetIcons {
    var backArrow: Image { get }
    var close: Image { get }
    var checkmark: Image { get }
    var chevronRight: Image { get }
    var chevronDown: Image { get }
    var settings: Image { get }
    var search: Image { get }
}

// MARK: - 6. Layout Config Container

/// Layout configuration containing spacing, radius, and icons
public protocol JetLayoutConfig {
    var spacing: JetSpacing { get }
    var radius: JetRadius { get }
    var icons: JetIcons { get }
}

// MARK: - 7. Master Theme Config

/// Master theme configuration protocol
/// Host apps implement this to provide their custom theme
public protocol JetThemeConfig {
    /// Color palette
    var colors: JetColorPalette { get }
    /// Typography (fonts)
    var fonts: JetTypography { get }
    /// Layout configuration (spacing, radius, icons)
    var layout: JetLayoutConfig { get }
}