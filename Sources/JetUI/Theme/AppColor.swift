//
//  AppColor.swift
//  JetUI
//
//  Unified color management for the application
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Hex → Color
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
// MARK: - Hex → UIColor
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

// MARK: - 颜色库
public enum AppColor {
    // Brand
    public static let themeColor = Color(hex: 0x2786D5)
    public static let subscripBackColor = Color(hex: 0x071F4C)

    
    public static let primaryBackground = Color(hex: 0x161615)
    public static let primary700 = Color(hex: 0x212121)
    public static let primary300 = Color(hex: 0xFFC74D)
    public static let primary100 = Color(hex: 0xFFE7B3)
    
    // Neutral
    public static let gray900 = Color(hex: 0x1A1A1A)
    public static let gray901 = Color(hex: 0x252525)
    public static let gray902 = Color(hex: 0x151515)
    public static let gray700 = Color(hex: 0x4D4D4D)
    public static let gray500 = Color(hex: 0x8C8C8C)
    public static let gray300 = Color(hex: 0xD9D9D9)
    public static let gray100 = Color(hex: 0x757575)
    
    // Semantic
    public static let success = Color(hex: 0x1FAD66)
    public static let warning = Color(hex: 0xFFCC00)
    public static let error   = Color(hex: 0xF24822)
}

#if canImport(UIKit)
// UIKit 使用
public extension UIColor {
    static let appPrimary500 = UIColor(hex: 0xFFA800)
    static let appPrimary600 = UIColor(hex: 0xDB9300)
    static let appPrimary700 = UIColor(hex: 0xB37700)
    static let appPrimary300 = UIColor(hex: 0xFFC74D)
    static let appPrimary100 = UIColor(hex: 0xFFE7B3)

    static let appGray900 = UIColor(hex: 0x1A1A1A)
    static let appGray700 = UIColor(hex: 0x4D4D4D)
    static let appGray500 = UIColor(hex: 0x8C8C8C)
    static let appGray300 = UIColor(hex: 0xD9D9D9)
    static let appGray100 = UIColor(hex: 0xF5F5F5)

    static let appSuccess = UIColor(hex: 0x1FAD66)
    static let appWarning = UIColor(hex: 0xFFCC00)
    static let appError   = UIColor(hex: 0xF24822)
}

public extension Color {
    /// 转成 8 位 hex 字符串，如 "#FF0000FF"
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

    /// 从 hex 构造颜色，支持 #RRGGBB / #RRGGBBAA
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
    /// 转成 8 位 hex 字符串，如 "#FF0000FF"
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
