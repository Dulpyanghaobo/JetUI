//
//  View+Jet.swift
//  JetUI
//
//  SwiftUI View extensions
//

import SwiftUI

// MARK: - Navigation Back Arrow

/// Configuration for back arrow modifier
public struct JetBackArrowConfig {
    public let iconSystemName: String
    public let iconColor: Color
    public let backgroundColor: Color
    
    public init(
        iconSystemName: String = "chevron.left",
        iconColor: Color = .white,
        backgroundColor: Color = .black
    ) {
        self.iconSystemName = iconSystemName
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
    }
    
    /// Default dark theme config
    public static let dark = JetBackArrowConfig(
        iconSystemName: "chevron.left",
        iconColor: .white,
        backgroundColor: .black
    )
    
    /// Light theme config
    public static let light = JetBackArrowConfig(
        iconSystemName: "chevron.left",
        iconColor: .black,
        backgroundColor: .white
    )
}

private struct JetBackArrowModifier: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    
    let config: JetBackArrowConfig
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: config.iconSystemName)
                            .foregroundColor(config.iconColor)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .toolbarBackground(config.backgroundColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
    }
}

public extension View {
    
    /// Add a unified back arrow to navigation bar
    /// - Parameter config: Back arrow configuration
    /// - Returns: Modified view
    func jet_backArrow(_ config: JetBackArrowConfig = .dark) -> some View {
        modifier(JetBackArrowModifier(config: config))
    }
}

// MARK: - Conditional Modifiers

public extension View {
    
    /// Apply a modifier conditionally
    /// - Parameters:
    ///   - condition: Condition to evaluate
    ///   - transform: Transform to apply if condition is true
    /// - Returns: Modified view
    @ViewBuilder
    func jet_if<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Apply a modifier conditionally with else branch
    /// - Parameters:
    ///   - condition: Condition to evaluate
    ///   - ifTransform: Transform to apply if condition is true
    ///   - elseTransform: Transform to apply if condition is false
    /// - Returns: Modified view
    @ViewBuilder
    func jet_if<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
    
    /// Apply a modifier if value is not nil
    /// - Parameters:
    ///   - value: Optional value
    ///   - transform: Transform to apply with unwrapped value
    /// - Returns: Modified view
    @ViewBuilder
    func jet_ifLet<Value, Transform: View>(
        _ value: Value?,
        transform: (Self, Value) -> Transform
    ) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Frame Helpers

public extension View {
    
    /// Fill available space
    func jet_fillMaxSize(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
    
    /// Fill available width
    func jet_fillMaxWidth(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }
    
    /// Fill available height
    func jet_fillMaxHeight(alignment: Alignment = .center) -> some View {
        frame(maxHeight: .infinity, alignment: alignment)
    }
}

// MARK: - Border & Shadow

public extension View {
    
    /// Add rounded border
    func jet_border(
        _ color: Color,
        cornerRadius: CGFloat,
        lineWidth: CGFloat = 1
    ) -> some View {
        self
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
            )
    }
    
    /// Add card-like shadow
    func jet_cardShadow(
        color: Color = .black.opacity(0.1),
        radius: CGFloat = 8,
        x: CGFloat = 0,
        y: CGFloat = 4
    ) -> some View {
        shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - Keyboard

public extension View {
    
    /// Hide keyboard when tapped
    func jet_hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}