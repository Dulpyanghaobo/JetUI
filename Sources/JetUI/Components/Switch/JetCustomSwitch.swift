//
//  JetCustomSwitch.swift
//  JetUI
//
//  Custom styled toggle switch component
//

import SwiftUI

// MARK: - JetCustomSwitch

/// A custom styled toggle switch with configurable colors and appearance
/// Features a rectangular design with smooth animation
public struct JetCustomSwitch: View {
    
    /// Binding to the toggle state
    @Binding public var isOn: Bool
    
    /// Whether the switch is enabled for interaction
    public var isEnabled: Bool
    
    /// Color when the switch is ON
    public var onColor: Color
    
    /// Color when the switch is OFF
    public var offColor: Color
    
    /// Border color
    public var borderColor: Color
    
    /// Border opacity
    public var borderOpacity: Double
    
    /// Width of the switch
    public var width: CGFloat
    
    /// Height of the switch
    public var height: CGFloat
    
    /// Corner radius of the outer container
    public var cornerRadius: CGFloat
    
    /// Corner radius of the inner thumb
    public var thumbCornerRadius: CGFloat
    
    /// Initialize a custom switch
    /// - Parameters:
    ///   - isOn: Binding to the toggle state
    ///   - isEnabled: Whether the switch is enabled (default: true)
    ///   - onColor: Color when ON (default: AppColor.themeColor)
    ///   - offColor: Color when OFF (default: white)
    ///   - borderColor: Border color (default: white)
    ///   - borderOpacity: Border opacity (default: 0.4)
    ///   - width: Total width (default: 60)
    ///   - height: Total height (default: 30)
    ///   - cornerRadius: Outer corner radius (default: 3)
    ///   - thumbCornerRadius: Inner thumb corner radius (default: 3)
    public init(
        isOn: Binding<Bool>,
        isEnabled: Bool = true,
        onColor: Color = AppColor.themeColor,
        offColor: Color = .white,
        borderColor: Color = .white,
        borderOpacity: Double = 0.4,
        width: CGFloat = 60,
        height: CGFloat = 30,
        cornerRadius: CGFloat = 3,
        thumbCornerRadius: CGFloat = 3
    ) {
        self._isOn = isOn
        self.isEnabled = isEnabled
        self.onColor = onColor
        self.offColor = offColor
        self.borderColor = borderColor
        self.borderOpacity = borderOpacity
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.thumbCornerRadius = thumbCornerRadius
    }
    
    public var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            // Outer container with border
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor.opacity(borderOpacity), lineWidth: 1)
                .frame(width: width, height: height)
            
            // Inner thumb
            RoundedRectangle(cornerRadius: thumbCornerRadius)
                .fill(isOn ? onColor : offColor)
                .frame(width: thumbWidth, height: thumbHeight)
                .padding(1)
        }
        .contentShape(Rectangle())
        .allowsHitTesting(isEnabled)
        .onTapGesture {
            guard isEnabled else { return }
            isOn.toggle()
        }
        .opacity(isEnabled ? 1 : 0.7)
        .animation(.easeInOut(duration: 0.15), value: isOn)
    }
    
    // MARK: - Computed Properties
    
    private var thumbWidth: CGFloat {
        (width - 6) * 0.55  // Approximately 34pt for 60pt width
    }
    
    private var thumbHeight: CGFloat {
        height - 6  // 24pt for 30pt height
    }
}

// MARK: - Convenience Initializers

public extension JetCustomSwitch {
    
    /// Create a pill-style switch (rounded ends)
    static func pill(
        isOn: Binding<Bool>,
        isEnabled: Bool = true,
        onColor: Color = AppColor.themeColor,
        offColor: Color = .white
    ) -> JetCustomSwitch {
        JetCustomSwitch(
            isOn: isOn,
            isEnabled: isEnabled,
            onColor: onColor,
            offColor: offColor,
            cornerRadius: 15,
            thumbCornerRadius: 12
        )
    }
    
    /// Create a square-style switch
    static func square(
        isOn: Binding<Bool>,
        isEnabled: Bool = true,
        onColor: Color = AppColor.themeColor,
        offColor: Color = .white
    ) -> JetCustomSwitch {
        JetCustomSwitch(
            isOn: isOn,
            isEnabled: isEnabled,
            onColor: onColor,
            offColor: offColor,
            cornerRadius: 3,
            thumbCornerRadius: 3
        )
    }
}

// MARK: - Preview

#if DEBUG
struct JetCustomSwitch_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isOn1 = false
        @State private var isOn2 = true
        @State private var isOn3 = false
        
        var body: some View {
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Default style
                    HStack {
                        Text("Default Switch")
                            .foregroundColor(.white)
                        Spacer()
                        JetCustomSwitch(isOn: $isOn1)
                    }
                    
                    // Pill style
                    HStack {
                        Text("Pill Switch")
                            .foregroundColor(.white)
                        Spacer()
                        JetCustomSwitch.pill(isOn: $isOn2)
                    }
                    
                    // Disabled
                    HStack {
                        Text("Disabled Switch")
                            .foregroundColor(.white)
                        Spacer()
                        JetCustomSwitch(isOn: $isOn3, isEnabled: false)
                    }
                }
                .padding(24)
            }
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}
#endif