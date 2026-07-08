//
//  AppFont.swift
//  JetUI
//
//  Unified font management for the application.
//  Fonts are now read from the configured theme via JetThemeRegistry.theme.fonts.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - App Fonts (Proxy Pattern)

/// Unified font accessor that reads from the configured theme.
/// These computed properties delegate to `JetThemeRegistry.theme.fonts`.
public enum AppFont {
    
    // MARK: Display Fonts
    
    /// Extra extra large display font (70pt hero text)
    public static var displayXXL: Font { JetThemeRegistry.theme.fonts.displayXXL }
    
    /// Extra large display font (34pt large title)
    public static var displayXL: Font { JetThemeRegistry.theme.fonts.displayXL }
    
    /// Large display font (32pt title)
    public static var displayL: Font { JetThemeRegistry.theme.fonts.displayL }
    
    // MARK: Heading Fonts
    
    /// Large heading (20pt)
    public static var headingL: Font { JetThemeRegistry.theme.fonts.headingL }
    
    /// Medium heading (24pt)
    public static var headingM: Font { JetThemeRegistry.theme.fonts.headingM }
    
    /// Small heading (16pt)
    public static var headingS: Font { JetThemeRegistry.theme.fonts.headingS }
    
    // MARK: Body Fonts
    
    /// Large body text (16pt regular)
    public static var bodyL: Font { JetThemeRegistry.theme.fonts.bodyL }
    
    /// Medium body text variant 1 (18pt medium)
    public static var bodyM1: Font { JetThemeRegistry.theme.fonts.bodyM1 }
    
    /// Medium body text (16pt medium)
    public static var bodyM: Font { JetThemeRegistry.theme.fonts.bodyM }
    
    /// Small body text (14pt)
    public static var bodyS: Font { JetThemeRegistry.theme.fonts.bodyS }
    
    // MARK: Utility Fonts
    
    /// Caption text (12pt for labels)
    public static var caption: Font { JetThemeRegistry.theme.fonts.caption }
    
    /// Footnote text (12pt for fine print)
    public static var footnote: Font { JetThemeRegistry.theme.fonts.footnote }
    
    /// Footnote variant 2 (14pt)
    public static var footnote2: Font { JetThemeRegistry.theme.fonts.footnote2 }

    // MARK: Legacy App Token Aliases
    //
    // These aliases deliberately resolve through the active JetUI theme. They
    // are here for apps migrating from local AppFont definitions.

    public static var headingL1: Font { headingM }
    public static var headingL2: Font { headingM }
    public static var headingS2: Font { bodyM1 }
    public static var heading3: Font { headingS }
    public static var heading4: Font { bodyS }
    public static var bodyS2: Font { footnote }
    public static var tabbarTitle: Font { caption }
    public static var tabbarTitle2: Font { footnote }
    public static var bodyS3: Font { footnote2 }
    public static var title3: Font { displayL }
    public static var button1: Font { bodyM }
    public static var button2: Font { headingS }
    public static var button3: Font { headingL }
    
    // MARK: - UIKit Support
    
    #if canImport(UIKit)
    /// UIKit font variants with dynamic type support
    public enum ui {
        public static func displayXL() -> UIFont { dynamic("Avenir-Black", size: 34, style: .largeTitle, weight: .black) }
        public static func displayL() -> UIFont { dynamic("Avenir-Black", size: 32, style: .title1, weight: .black) }
        public static func title3() -> UIFont { dynamic("Avenir-Heavy", size: 30, style: .title1, weight: .heavy) }
        public static func headingM() -> UIFont { dynamic("Avenir-Heavy", size: 24, style: .title2, weight: .heavy) }
        public static func headingL1() -> UIFont { dynamic("Avenir-Book", size: 26, style: .title1, weight: .regular) }
        public static func headingL2() -> UIFont { dynamic("Avenir-Book", size: 24, style: .title1, weight: .regular) }
        public static func headingL() -> UIFont { dynamic("Avenir-Heavy", size: 20, style: .title3, weight: .semibold) }
        public static func headingS2() -> UIFont { dynamic("Avenir-Heavy", size: 18, style: .headline, weight: .semibold) }
        public static func heading3() -> UIFont { dynamic("Avenir-Heavy", size: 16, style: .headline, weight: .semibold) }
        public static func heading4() -> UIFont { dynamic("Avenir-Heavy", size: 14, style: .subheadline, weight: .semibold) }
        public static func headingS() -> UIFont { dynamic("Avenir-Medium", size: 16, style: .headline, weight: .medium) }
        public static func bodyL() -> UIFont { dynamic("Avenir-Book", size: 16, style: .body, weight: .regular) }
        public static func bodyM() -> UIFont { dynamic("Avenir-Medium", size: 16, style: .body, weight: .medium) }
        public static func bodyS() -> UIFont { dynamic("Avenir-Medium", size: 14, style: .callout, weight: .medium) }
        public static func bodyS2() -> UIFont { dynamic("Avenir-Roman", size: 12, style: .subheadline, weight: .regular) }
        public static func bodyS3() -> UIFont { dynamic("Avenir-Roman", size: 14, style: .subheadline, weight: .regular) }
        public static func caption() -> UIFont { dynamic("Avenir-Medium", size: 12, style: .caption1, weight: .medium) }
        public static func footnote() -> UIFont { dynamic("Avenir-Book", size: 12, style: .footnote, weight: .regular) }
        public static func button1() -> UIFont { dynamic("Avenir-Roman", size: 16, style: .headline, weight: .regular) }
        public static func button2() -> UIFont { dynamic("Avenir-Heavy", size: 16, style: .headline, weight: .semibold) }
        public static func button3() -> UIFont { dynamic("Avenir-Roman", size: 20, style: .title3, weight: .regular) }
        public static func tabbarTitle() -> UIFont { dynamic("Avenir-Heavy", size: 10, style: .caption2, weight: .semibold) }
        public static func tabbarTitle2() -> UIFont { dynamic("Avenir-Heavy", size: 12, style: .caption1, weight: .semibold) }

        private static func dynamic(_ name: String, size: CGFloat, style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
            let base = UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size, weight: weight)
            return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
        }
    }
    #endif
}

#if canImport(UIKit)
public extension UILabel {
    enum AppStyle {
        case displayXL, displayL, title3
        case headingM, headingL1, headingL2, headingL, headingS2, heading3, heading4, headingS
        case bodyL, bodyM, bodyS, bodyS2, bodyS3
        case caption, footnote
        case button1, button2, button3
        case tabbarTitle, tabbarTitle2
    }

    func applyAppFont(_ style: AppStyle) {
        switch style {
        case .displayXL: font = AppFont.ui.displayXL()
        case .displayL: font = AppFont.ui.displayL()
        case .title3: font = AppFont.ui.title3()
        case .headingM: font = AppFont.ui.headingM()
        case .headingL1: font = AppFont.ui.headingL1()
        case .headingL2: font = AppFont.ui.headingL2()
        case .headingL: font = AppFont.ui.headingL()
        case .headingS2: font = AppFont.ui.headingS2()
        case .heading3: font = AppFont.ui.heading3()
        case .heading4: font = AppFont.ui.heading4()
        case .headingS: font = AppFont.ui.headingS()
        case .bodyL: font = AppFont.ui.bodyL()
        case .bodyM: font = AppFont.ui.bodyM()
        case .bodyS: font = AppFont.ui.bodyS()
        case .bodyS2: font = AppFont.ui.bodyS2()
        case .bodyS3: font = AppFont.ui.bodyS3()
        case .caption: font = AppFont.ui.caption()
        case .footnote: font = AppFont.ui.footnote()
        case .button1: font = AppFont.ui.button1()
        case .button2: font = AppFont.ui.button2()
        case .button3: font = AppFont.ui.button3()
        case .tabbarTitle: font = AppFont.ui.tabbarTitle()
        case .tabbarTitle2: font = AppFont.ui.tabbarTitle2()
        }
        adjustsFontForContentSizeCategory = true
        numberOfLines = numberOfLines == 0 ? 0 : numberOfLines
    }
}

public extension UIButton {
    func applyAppFontTitle(_ labelStyle: UILabel.AppStyle, state: UIControl.State = .normal) {
        let label = UILabel()
        label.applyAppFont(labelStyle)
        setTitleColor(titleColor(for: state) ?? tintColor, for: state)
        titleLabel?.font = label.font
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
}
#endif
