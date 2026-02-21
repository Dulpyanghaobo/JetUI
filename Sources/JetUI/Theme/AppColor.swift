//
//  AppColor.swift
//  JetUI
//
//  Unified semantic color management for the application.
//  Colors are read from the configured theme via JetUI.theme.colors.
//
//  ## Naming Convention (Semantic)
//  - Labels/Text: labelPrimary, labelSecondary, labelTertiary, labelDisabled
//  - Backgrounds: backgroundPrimary, backgroundSecondary, backgroundTertiary
//  - Brand: brandPrimary, brandSecondary
//  - Status: statusSuccess, statusWarning, statusError
//  - Surfaces: surfacePrimary, surfaceSecondary, surfaceElevated
//  - Accents: accentGold, accentBlue, accentGreen, accentPurple
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Hex → Color Extension

public extension Color {
    init(hex: UInt32) {
        let a, r, g, b: Double
        if hex > 0xFFFFFF {
            a = Double((hex & 0xFF000000) >> 24) / 255
            r = Double((hex & 0x00FF0000) >> 16) / 255
            g = Double((hex & 0x0000FF00) >> 8)  / 255
            b = Double( hex & 0x000000FF)        / 255
        } else {
            a = 1
            r = Double((hex & 0xFF0000) >> 16) / 255
            g = Double((hex & 0x00FF00) >> 8)  / 255
            b = Double( hex & 0x0000FF)        / 255
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

#if canImport(UIKit)
// MARK: - Hex → UIColor Extension

extension UIColor {
    convenience init(hex: UInt32) {
        let a, r, g, b: CGFloat
        if hex > 0xFFFFFF {
            a = CGFloat((hex & 0xFF000000) >> 24) / 255
            r = CGFloat((hex & 0x00FF0000) >> 16) / 255
            g = CGFloat((hex & 0x0000FF00) >> 8)  / 255
            b = CGFloat( hex & 0x000000FF)        / 255
        } else {
            a = 1
            r = CGFloat((hex & 0xFF0000) >> 16) / 255
            g = CGFloat((hex & 0x00FF00) >> 8)  / 255
            b = CGFloat( hex & 0x0000FF)        / 255
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
#endif

// MARK: - App Colors (Semantic Naming)

/// Unified color accessor using semantic naming convention.
/// All computed properties delegate to `JetUI.theme.colors`.
///
/// ## Semantic Categories
/// - **Label/Text**: For text content (primary, secondary, tertiary, disabled)
/// - **Background**: For view backgrounds (primary, secondary, tertiary)
/// - **Surface**: For card/elevated surfaces
/// - **Brand**: For brand identity colors
/// - **Status**: For state indicators (success, warning, error)
/// - **Accent**: For highlight and interactive elements
public enum AppColor {
    
    // MARK: - Label/Text Colors (Semantic)
    
    /// Primary text color - headings, important text, body text
    /// Use for: Titles, headings, main content text
    public static var labelPrimary: Color { JetUI.theme.colors.textPrimary }
    
    /// Secondary text color - descriptions, subtitles
    /// Use for: Subtitles, secondary information, descriptions
    public static var labelSecondary: Color { JetUI.theme.colors.textSecondary }
    
    /// Tertiary text color - placeholders, hints, captions
    /// Use for: Placeholder text, hints, less important info
    public static var labelTertiary: Color { JetUI.theme.colors.textTertiary }
    
    /// Disabled text color - inactive states
    /// Use for: Disabled buttons, inactive text
    public static var labelDisabled: Color { JetUI.theme.colors.textDisabled }
    
    // MARK: - Background Colors (Semantic)
    
    /// Primary background - main screen/view background
    /// Use for: Main view background, root containers
    public static var backgroundPrimary: Color { JetUI.theme.colors.backgroundPrimary }
    
    /// Secondary background - cards, sections, grouped content
    /// Use for: Card backgrounds, section backgrounds
    public static var backgroundSecondary: Color { JetUI.theme.colors.backgroundSecondary }
    
    /// Tertiary background - nested cards, modals, popups
    /// Use for: Modal backgrounds, nested containers
    public static var backgroundTertiary: Color { JetUI.theme.colors.backgroundTertiary }
    
    // MARK: - Surface Colors (Semantic)
    
    /// Primary surface - default card/container surface
    /// Use for: Card surfaces, list items
    public static var surfacePrimary: Color { JetUI.theme.colors.cardDark }
    
    /// Secondary surface - nested or lighter surface
    /// Use for: Nested cards, secondary containers
    public static var surfaceSecondary: Color { JetUI.theme.colors.surfaceLight }
    
    /// Elevated surface - raised elements, floating cards
    /// Use for: Floating action buttons, elevated cards
    public static var surfaceElevated: Color { JetUI.theme.colors.surfaceDark }
    
    // MARK: - Brand Colors (Semantic)
    
    /// Primary brand color - main theme/accent color
    /// Use for: Primary buttons, links, interactive elements
    public static var brandPrimary: Color { JetUI.theme.colors.brandPrimary }
    
    /// Secondary brand color - complementary brand element
    /// Use for: Secondary actions, subscription UI
    public static var brandSecondary: Color { JetUI.theme.colors.brandSecondary }
    
    // MARK: - Status Colors (Semantic)
    
    /// Success state color
    /// Use for: Success messages, completed states, positive feedback
    public static var statusSuccess: Color { JetUI.theme.colors.success }
    
    /// Warning state color
    /// Use for: Warning messages, caution states
    public static var statusWarning: Color { JetUI.theme.colors.warning }
    
    /// Error state color
    /// Use for: Error messages, destructive actions, alerts
    public static var statusError: Color { JetUI.theme.colors.error }
    
    // MARK: - Accent Colors (Semantic)
    
    /// Gold accent - premium features, coins, rewards
    /// Use for: Premium badges, coin indicators, rewards
    public static var accentGold: Color { JetUI.theme.colors.proGold }
    
    /// Gold highlight - sign-in rewards, achievements
    /// Use for: Achievement badges, special rewards
    public static var accentGoldHighlight: Color { JetUI.theme.colors.goldAccent }
    
    /// Dark gold - secondary gold variant
    /// Use for: Gold shadows, secondary premium elements
    public static var accentGoldDark: Color { JetUI.theme.colors.goldDark }
    
    /// Orange accent - highlights, attention
    /// Use for: Attention-grabbing elements, highlights
    public static var accentOrange: Color { JetUI.theme.colors.orangeAccent }
    
    /// Blue accent - XP, progress, information
    /// Use for: Progress indicators, XP displays, info badges
    public static var accentBlue: Color { JetUI.theme.colors.accentBlue }
    
    /// Green accent - growth, completion, success
    /// Use for: Growth indicators, completion states
    public static var accentGreen: Color { JetUI.theme.colors.growthGreen }
    
    /// Purple accent - premium, special features
    /// Use for: Premium gradients, special features
    public static var accentPurple: Color { JetUI.theme.colors.premiumPurple }
    
    /// Mint green - fresh success states
    /// Use for: Fresh success indicators
    public static var accentMint: Color { JetUI.theme.colors.mintGreen }
    
    // MARK: - Interactive Colors (Semantic)
    
    /// Link color - tappable text links
    /// Use for: Hyperlinks, clickable text
    public static var linkColor: Color { JetUI.theme.colors.linkBlue }
    
    /// Points/currency indicator color
    /// Use for: Points display, currency amounts
    public static var pointsColor: Color { JetUI.theme.colors.pointsYellow }
}

// MARK: - Color Utilities

public extension Color {
    /// Convert to 8-digit hex string, e.g., "#FF0000FF"
    func toHexString() -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }

        let rgba = (
            Int(r * 255) << 24 |
            Int(g * 255) << 16 |
            Int(b * 255) << 8  |
            Int(a * 255)
        )
        return String(format: "#%08X", rgba)
    }

    /// Create color from hex string, supports #RRGGBB / #RRGGBBAA
    init?(hexString: String?) {
        guard let hex = hexString?.trimmingCharacters(in: .whitespacesAndNewlines),
              hex.starts(with: "#"),
              let int = UInt32(hex.dropFirst(), radix: 16)
        else { return nil }

        let r, g, b, a: Double
        switch hex.count {
        case 7: // #RRGGBB
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >>  8) & 0xFF) / 255
            b = Double( int        & 0xFF) / 255
            a = 1
        case 9: // #RRGGBBAA
            r = Double((int >> 24) & 0xFF) / 255
            g = Double((int >> 16) & 0xFF) / 255
            b = Double((int >>  8) & 0xFF) / 255
            a = Double( int        & 0xFF) / 255
        default:
            return nil
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Migration Guide
/*
 ## Migration from Old Names to Semantic Names
 
 ### Text/Label Colors
 - gray900 → labelPrimary (darkest text)
 - gray700 → labelSecondary (secondary text)
 - gray500 → labelTertiary (tertiary/hint text)
 - gray300 → labelDisabled (disabled text)
 
 ### Background Colors
 - primaryBackground → backgroundPrimary
 - primary700 → backgroundSecondary
 - gray901 → backgroundTertiary
 
 ### Brand Colors
 - themeColor → brandPrimary
 - subscripBackColor → brandSecondary
 
 ### Status Colors
 - success → statusSuccess
 - warning → statusWarning
 - error → statusError
 
 ### Surface Colors
 - gray902 → surfaceElevated
 - (new) surfacePrimary - card backgrounds
 - (new) surfaceSecondary - nested surfaces
 
 ### Accent Colors (New)
 - accentGold - premium/coins
 - accentBlue - XP/progress
 - accentGreen - growth/success
 - accentPurple - premium features
 - accentOrange - highlights
 - accentMint - fresh success
 
 ### Interactive Colors (New)
 - linkColor - hyperlinks
 - pointsColor - currency display
 */
