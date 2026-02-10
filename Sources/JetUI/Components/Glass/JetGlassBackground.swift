//
//  JetGlassBackground.swift
//  JetUI
//
//  Glass/Blur effect components for iOS apps
//

import SwiftUI

// MARK: - JetBlurView

/// A UIViewRepresentable wrapper for UIVisualEffectView
/// Provides iOS blur effect in SwiftUI
public struct JetBlurView: UIViewRepresentable {
    
    /// The blur effect style
    public let style: UIBlurEffect.Style
    
    /// Initialize with a blur style
    /// - Parameter style: The UIBlurEffect.Style to apply
    public init(style: UIBlurEffect.Style = .systemUltraThinMaterialDark) {
        self.style = style
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// MARK: - JetGlassBackground

/// A glass-morphism style background view with blur effect and border
/// Perfect for creating modern, translucent UI elements
public struct JetGlassBackground: View {
    
    /// Corner radius of the glass background
    public let cornerRadius: CGFloat
    
    /// Blur effect style
    public let blurStyle: UIBlurEffect.Style
    
    /// Border color
    public let borderColor: Color
    
    /// Border opacity
    public let borderOpacity: Double
    
    /// Border line width
    public let borderWidth: CGFloat
    
    /// Initialize a glass background
    /// - Parameters:
    ///   - cornerRadius: Corner radius (default: 12)
    ///   - blurStyle: Blur effect style (default: .systemUltraThinMaterialDark)
    ///   - borderColor: Border color (default: .white)
    ///   - borderOpacity: Border opacity (default: 0.4)
    ///   - borderWidth: Border line width (default: 0.5)
    public init(
        cornerRadius: CGFloat = 12,
        blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark,
        borderColor: Color = .white,
        borderOpacity: Double = 0.4,
        borderWidth: CGFloat = 0.5
    ) {
        self.cornerRadius = cornerRadius
        self.blurStyle = blurStyle
        self.borderColor = borderColor
        self.borderOpacity = borderOpacity
        self.borderWidth = borderWidth
    }
    
    public var body: some View {
        JetBlurView(style: blurStyle)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .inset(by: -0.25)
                    .stroke(borderColor.opacity(borderOpacity), lineWidth: borderWidth)
            )
    }
}

// MARK: - View Extension

public extension View {
    
    /// Apply a glass background to the view
    /// - Parameters:
    ///   - cornerRadius: Corner radius (default: 12)
    ///   - blurStyle: Blur effect style (default: .systemUltraThinMaterialDark)
    /// - Returns: A view with glass background
    func glassBackground(
        cornerRadius: CGFloat = 12,
        blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark
    ) -> some View {
        self.background(
            JetGlassBackground(cornerRadius: cornerRadius, blurStyle: blurStyle)
        )
    }
}

// MARK: - Preview

#if DEBUG
struct JetGlassBackground_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background image or gradient
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Glass card
            VStack(spacing: 16) {
                Text("Glass Background")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Beautiful blur effect")
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(24)
            .glassBackground(cornerRadius: 16)
        }
    }
}
#endif