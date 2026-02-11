//
//  JetLayoutExtensions.swift
//  JetUI
//
//  Helper extensions for easy access to layout tokens.
//  Provides syntactic sugar and SwiftUI view modifiers for consistent design.
//

import SwiftUI

// MARK: - AppTheme Convenience Accessors

/// Convenience struct for quick access to theme tokens.
/// Usage: `AppTheme.spacing.m` or `AppTheme.radius.medium`
public enum AppTheme {
    /// Quick access to spacing tokens
    public static var spacing: JetSpacing { JetUI.theme.layout.spacing }
    
    /// Quick access to radius tokens
    public static var radius: JetRadius { JetUI.theme.layout.radius }
    
    /// Quick access to icon tokens
    public static var icons: JetIcons { JetUI.theme.layout.icons }
    
    /// Quick access to color tokens
    public static var colors: JetColorPalette { JetUI.theme.colors }
    
    /// Quick access to font tokens
    public static var fonts: JetTypography { JetUI.theme.fonts }
}

// MARK: - View Extensions for Spacing

public extension View {
    
    /// Apply padding using theme spacing tokens.
    /// - Parameters:
    ///   - edges: The edges to apply padding to
    ///   - size: KeyPath to the spacing value (e.g., \.m for medium)
    /// - Returns: Modified view with themed padding
    ///
    /// Usage: `.jetPadding(.all, \.m)` or `.jetPadding(.horizontal, \.l)`
    func jetPadding(_ edges: Edge.Set = .all, _ size: KeyPath<JetSpacing, CGFloat>) -> some View {
        self.padding(edges, JetUI.theme.layout.spacing[keyPath: size])
    }
    
    /// Apply equal padding on all sides using theme spacing.
    /// - Parameter size: KeyPath to the spacing value
    /// - Returns: Modified view with themed padding
    func jetPadding(_ size: KeyPath<JetSpacing, CGFloat>) -> some View {
        self.padding(JetUI.theme.layout.spacing[keyPath: size])
    }
    
    /// Apply corner radius using theme radius tokens.
    /// - Parameter size: KeyPath to the radius value (e.g., \.medium)
    /// - Returns: Modified view with themed corner radius
    ///
    /// Usage: `.jetCornerRadius(\.medium)` or `.jetCornerRadius(\.pill)`
    func jetCornerRadius(_ size: KeyPath<JetRadius, CGFloat>) -> some View {
        self.cornerRadius(JetUI.theme.layout.radius[keyPath: size])
    }
    
    /// Apply background with corner radius using theme tokens.
    /// - Parameters:
    ///   - color: Background color
    ///   - radius: KeyPath to the radius value
    /// - Returns: Modified view with themed background and corner radius
    func jetBackground(_ color: Color, radius: KeyPath<JetRadius, CGFloat>) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: JetUI.theme.layout.radius[keyPath: radius])
                .fill(color)
        )
    }
    
    /// Apply frame with spacing-based sizing.
    /// - Parameters:
    ///   - width: Optional width using spacing keypath
    ///   - height: Optional height using spacing keypath
    /// - Returns: Modified view with themed frame
    func jetFrame(
        width: KeyPath<JetSpacing, CGFloat>? = nil,
        height: KeyPath<JetSpacing, CGFloat>? = nil
    ) -> some View {
        let spacing = JetUI.theme.layout.spacing
        return self.frame(
            width: width.map { spacing[keyPath: $0] },
            height: height.map { spacing[keyPath: $0] }
        )
    }
}

// MARK: - VStack/HStack Spacing Helpers

public extension VStack {
    /// Create VStack with themed spacing.
    /// - Parameters:
    ///   - alignment: Horizontal alignment
    ///   - spacing: KeyPath to the spacing value
    ///   - content: Content builder
    init(
        alignment: HorizontalAlignment = .center,
        spacing: KeyPath<JetSpacing, CGFloat>,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            alignment: alignment,
            spacing: JetUI.theme.layout.spacing[keyPath: spacing],
            content: content
        )
    }
}

public extension HStack {
    /// Create HStack with themed spacing.
    /// - Parameters:
    ///   - alignment: Vertical alignment
    ///   - spacing: KeyPath to the spacing value
    ///   - content: Content builder
    init(
        alignment: VerticalAlignment = .center,
        spacing: KeyPath<JetSpacing, CGFloat>,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            alignment: alignment,
            spacing: JetUI.theme.layout.spacing[keyPath: spacing],
            content: content
        )
    }
}

// MARK: - RoundedRectangle Helper

public extension RoundedRectangle {
    /// Create RoundedRectangle with themed corner radius.
    /// - Parameter radius: KeyPath to the radius value
    init(radius: KeyPath<JetRadius, CGFloat>) {
        self.init(cornerRadius: JetUI.theme.layout.radius[keyPath: radius])
    }
}

// MARK: - Spacer Helpers

/// A spacer view using themed spacing.
public struct JetSpacer: View {
    private let size: CGFloat
    private let axis: Axis
    
    /// Create a spacer with themed size.
    /// - Parameters:
    ///   - size: KeyPath to the spacing value
    ///   - axis: Direction of the spacer (horizontal or vertical)
    public init(_ size: KeyPath<JetSpacing, CGFloat>, axis: Axis = .vertical) {
        self.size = JetUI.theme.layout.spacing[keyPath: size]
        self.axis = axis
    }
    
    public var body: some View {
        switch axis {
        case .horizontal:
            Spacer().frame(width: size)
        case .vertical:
            Spacer().frame(height: size)
        }
    }
}

// MARK: - Divider with Spacing

public struct JetDivider: View {
    private let topSpacing: CGFloat
    private let bottomSpacing: CGFloat
    private let color: Color
    
    /// Create a divider with themed spacing.
    /// - Parameters:
    ///   - spacing: KeyPath to the spacing value for both top and bottom
    ///   - color: Divider color (defaults to gray)
    public init(
        spacing: KeyPath<JetSpacing, CGFloat> = \.m,
        color: Color = Color.gray.opacity(0.3)
    ) {
        self.topSpacing = JetUI.theme.layout.spacing[keyPath: spacing]
        self.bottomSpacing = JetUI.theme.layout.spacing[keyPath: spacing]
        self.color = color
    }
    
    /// Create a divider with custom top and bottom spacing.
    public init(
        topSpacing: KeyPath<JetSpacing, CGFloat>,
        bottomSpacing: KeyPath<JetSpacing, CGFloat>,
        color: Color = Color.gray.opacity(0.3)
    ) {
        let spacing = JetUI.theme.layout.spacing
        self.topSpacing = spacing[keyPath: topSpacing]
        self.bottomSpacing = spacing[keyPath: bottomSpacing]
        self.color = color
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: topSpacing)
            Divider().background(color)
            Spacer().frame(height: bottomSpacing)
        }
    }
}

// MARK: - Icon Button Helper

public struct JetIconButton: View {
    private let icon: Image
    private let action: () -> Void
    private let size: CGFloat
    private let color: Color
    
    /// Create an icon button using themed icons.
    /// - Parameters:
    ///   - icon: KeyPath to the icon
    ///   - size: Icon size (default 24)
    ///   - color: Icon color
    ///   - action: Button action
    public init(
        _ icon: KeyPath<JetIcons, Image>,
        size: CGFloat = 24,
        color: Color = .primary,
        action: @escaping () -> Void
    ) {
        self.icon = JetUI.theme.layout.icons[keyPath: icon]
        self.size = size
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(color)
        }
    }
}
