//
//  AppColor.swift
//  JetUI
//
//  Unified color management for the application.
//  Colors are now read from the configured theme via JetUI.theme.colors.
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

// MARK: - App Colors (Proxy Pattern)

/// Unified color accessor that reads from the configured theme.
/// These computed properties delegate to `JetUI.theme.colors`.
public enum AppColor {
    
    // MARK: Brand Colors
    
    /// Primary theme/brand color
    public static var themeColor: Color { JetUI.theme.colors.brandPrimary }
    
    /// Subscription background color
    public static var subscripBackColor: Color { JetUI.theme.colors.brandSecondary }
    
    // MARK: Background Colors
    
    /// Primary background color
    public static var primaryBackground: Color { JetUI.theme.colors.backgroundPrimary }
    
    /// Secondary background (cards, sections)
    public static var primary700: Color { JetUI.theme.colors.backgroundSecondary }
    
    /// Primary accent light
    public static var primary300: Color { Color(hex: 0xFFC74D) }
    
    /// Primary accent very light
    public static var primary100: Color { Color(hex: 0xFFE7B3) }
    
    // MARK: Gray Scale
    
    /// Darkest gray (near black)
    public static var gray900: Color { JetUI.theme.colors.gray900 }
    
    /// Very dark gray (cards)
    public static var gray901: Color { JetUI.theme.colors.gray800 }
    
    /// Dark background variant
    public static var gray902: Color { Color(hex: 0x151515) }
    
    /// Dark gray
    public static var gray700: Color { JetUI.theme.colors.gray700 }
    
    /// Medium gray
    public static var gray500: Color { JetUI.theme.colors.gray500 }
    
    /// Light gray
    public static var gray300: Color { JetUI.theme.colors.gray300 }
    
    /// Very light gray
    public static var gray100: Color { JetUI.theme.colors.gray100 }
    
    // MARK: Semantic Colors
    
    /// Success state color
    public static var success: Color { JetUI.theme.colors.success }
    
    /// Warning state color
    public static var warning: Color { JetUI.theme.colors.warning }
    
    /// Error state color
    public static var error: Color { JetUI.theme.colors.error }
}

#if canImport(UIKit)
// MARK: - UIKit Color Extensions

public extension UIColor {
    static var appPrimary500: UIColor { UIColor(hex: 0xFFA800) }
    static var appPrimary600: UIColor { UIColor(hex: 0xDB9300) }
    static var appPrimary700: UIColor { UIColor(hex: 0xB37700) }
    static var appPrimary300: UIColor { UIColor(hex: 0xFFC74D) }
    static var appPrimary100: UIColor { UIColor(hex: 0xFFE7B3) }

    static var appGray900: UIColor { UIColor(hex: 0x1A1A1A) }
    static var appGray700: UIColor { UIColor(hex: 0x4D4D4D) }
    static var appGray500: UIColor { UIColor(hex: 0x8C8C8C) }
    static var appGray300: UIColor { UIColor(hex: 0xD9D9D9) }
    static var appGray100: UIColor { UIColor(hex: 0xF5F5F5) }

    static var appSuccess: UIColor { UIColor(hex: 0x1FAD66) }
    static var appWarning: UIColor { UIColor(hex: 0xFFCC00) }
    static var appError: UIColor { UIColor(hex: 0xF24822) }
}

// MARK: - Color ↔ Hex String Conversion

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

public extension UIColor {
    /// Convert to 8-digit hex string, e.g., "#FF0000FF"
    func toHexString() -> String? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }

        let rgba = (
            Int(r * 255) << 24 |
            Int(g * 255) << 16 |
            Int(b * 255) << 8  |
            Int(a * 255)
        )
        return String(format: "#%08X", rgba)
    }
}
#endif