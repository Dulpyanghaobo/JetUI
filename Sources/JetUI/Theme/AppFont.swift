//
//  AppFont.swift
//  JetUI
//
//  Unified font management for the application.
//  Fonts are now read from the configured theme via JetUI.theme.fonts.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - App Fonts (Proxy Pattern)

/// Unified font accessor that reads from the configured theme.
/// These computed properties delegate to `JetUI.theme.fonts`.
public enum AppFont {
    
    // MARK: Display Fonts
    
    /// Extra extra large display font (70pt hero text)
    public static var displayXXL: Font { JetUI.theme.fonts.displayXXL }
    
    /// Extra large display font (34pt large title)
    public static var displayXL: Font { JetUI.theme.fonts.displayXL }
    
    /// Large display font (32pt title)
    public static var displayL: Font { JetUI.theme.fonts.displayL }
    
    // MARK: Heading Fonts
    
    /// Large heading (20pt)
    public static var headingL: Font { JetUI.theme.fonts.headingL }
    
    /// Medium heading (24pt)
    public static var headingM: Font { JetUI.theme.fonts.headingM }
    
    /// Small heading (16pt)
    public static var headingS: Font { JetUI.theme.fonts.headingS }
    
    // MARK: Body Fonts
    
    /// Large body text (16pt regular)
    public static var bodyL: Font { JetUI.theme.fonts.bodyL }
    
    /// Medium body text variant 1 (18pt medium)
    public static var bodyM1: Font { JetUI.theme.fonts.bodyM1 }
    
    /// Medium body text (16pt medium)
    public static var bodyM: Font { JetUI.theme.fonts.bodyM }
    
    /// Small body text (14pt)
    public static var bodyS: Font { JetUI.theme.fonts.bodyS }
    
    // MARK: Utility Fonts
    
    /// Caption text (12pt for labels)
    public static var caption: Font { JetUI.theme.fonts.caption }
    
    /// Footnote text (12pt for fine print)
    public static var footnote: Font { JetUI.theme.fonts.footnote }
    
    /// Footnote variant 2 (14pt)
    public static var footnote2: Font { JetUI.theme.fonts.footnote2 }
    
    // MARK: - UIKit Support
    
    #if canImport(UIKit)
    /// UIKit font variants with dynamic type support
    public enum ui {
        public static func displayXL() -> UIFont { dynamic("Quicksand-Bold", size: 34, style: .largeTitle) }
        public static func displayL() -> UIFont { dynamic("Quicksand-Bold", size: 28, style: .title1) }
        public static func headingM() -> UIFont { dynamic("Quicksand-Medium", size: 22, style: .title2) }
        public static func headingS() -> UIFont { dynamic("Quicksand-Medium", size: 20, style: .title3) }
        public static func bodyM() -> UIFont { dynamic("Quicksand-Regular", size: 17, style: .body) }
        public static func bodyS() -> UIFont { dynamic("Quicksand-Regular", size: 15, style: .callout) }
        public static func caption() -> UIFont { dynamic("Quicksand-Medium", size: 13, style: .caption1) }
        public static func footnote() -> UIFont { dynamic("Quicksand-Regular", size: 11, style: .footnote) }

        private static func dynamic(_ name: String, size: CGFloat, style: UIFont.TextStyle) -> UIFont {
            let base = UIFont(name: name, size: size)!
            return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
        }
    }
    #endif
}
