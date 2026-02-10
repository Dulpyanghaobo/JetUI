//
//  JetCustomAlertView.swift
//  JetUI
//
//  Customizable alert view with configurable styling
//

import SwiftUI

// MARK: - Alert Configuration

/// Configuration for JetCustomAlertView
public struct JetAlertConfig {
    public let title: String
    public let message: String
    public let buttonTitle: String
    public let iconImage: Image?
    public let themeColor: Color
    public let onPrimary: () -> Void
    public let onClose: () -> Void
    public let cancelAction: (() -> Void)?
    public let cancelButtonTitle: String?
    
    /// Full initializer
    public init(
        title: String,
        message: String,
        buttonTitle: String,
        iconImage: Image? = nil,
        themeColor: Color = .blue,
        onPrimary: @escaping () -> Void,
        onClose: @escaping () -> Void,
        cancelAction: (() -> Void)? = nil,
        cancelButtonTitle: String? = nil
    ) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.iconImage = iconImage
        self.themeColor = themeColor
        self.onPrimary = onPrimary
        self.onClose = onClose
        self.cancelAction = cancelAction
        self.cancelButtonTitle = cancelButtonTitle
    }
}

// MARK: - Alert View

/// Customizable alert view component
public struct JetCustomAlertView: View {
    
    public let config: JetAlertConfig
    
    public init(config: JetAlertConfig) {
        self.config = config
    }
    
    public var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Color.black.opacity(0.45)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top icon
                topIconView
                    .zIndex(1)
                
                // Content card
                contentCardView
                    .offset(y: -32)
            }
            .padding(.horizontal, 60)
        }
    }
    
    // MARK: - Subviews
    
    private var topIconView: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 64, height: 64)
            
            if let icon = config.iconImage {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            } else {
                Image(systemName: "info.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(config.themeColor)
                    .frame(width: 50, height: 50)
            }
        }
    }
    
    private var contentCardView: some View {
        VStack(alignment: .center, spacing: 12) {
            // Close button
            closeButton
            
            // Title
            Text(config.title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0, green: 0, blue: 0))
            
            // Message
            Text(config.message)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.5))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
            
            // Primary button
            primaryButton
            
            // Cancel button (optional)
            if let cancelTitle = config.cancelButtonTitle,
               let cancelAction = config.cancelAction {
                cancelButton(title: cancelTitle, action: cancelAction)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
    
    private var closeButton: some View {
        HStack {
            Spacer()
            Button(action: config.onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(
                        Circle()
                            .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                    )
            }
        }
    }
    
    private var primaryButton: some View {
        Button(action: config.onPrimary) {
            Text(config.buttonTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(config.themeColor)
                .clipShape(RoundedRectangle(cornerRadius: 23))
        }
    }
    
    private func cancelButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .clipShape(RoundedRectangle(cornerRadius: 23))
        }
    }
}

// MARK: - Storage Quota Alert

/// Storage quota warning alert configuration
public struct JetStorageQuotaAlertConfig {
    public let message: String
    public let expandButtonTitle: String
    public let cleanupButtonTitle: String
    public let onExpand: () -> Void
    public let onCleanUp: () -> Void
    public let onClose: () -> Void
    
    public init(
        message: String,
        expandButtonTitle: String = "Expand capacity",
        cleanupButtonTitle: String = "Clean up",
        onExpand: @escaping () -> Void,
        onCleanUp: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        self.message = message
        self.expandButtonTitle = expandButtonTitle
        self.cleanupButtonTitle = cleanupButtonTitle
        self.onExpand = onExpand
        self.onCleanUp = onCleanUp
        self.onClose = onClose
    }
}

/// Storage quota warning alert view
public struct JetStorageQuotaAlertView: View {
    public let config: JetStorageQuotaAlertConfig
    public let iconImage: Image?
    
    @State private var appeared: Bool = false
    
    public init(config: JetStorageQuotaAlertConfig, iconImage: Image? = nil) {
        self.config = config
        self.iconImage = iconImage
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Overlay
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { /* block background taps */ }
                
                // Dialog
                dialogCard(width: geo.size.width * 0.85)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .offset(y: -60)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1.0 : 0.95)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                appeared = true
            }
        }
    }
    
    private func dialogCard(width: CGFloat) -> some View {
        ZStack(alignment: .top) {
            // Card container
            VStack(spacing: 16) {
                // Top-right close
                HStack {
                    Spacer()
                    Button(action: config.onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(10)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                // Title
                Text("Insufficient space")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.18))
                    .multilineTextAlignment(.center)
                
                // Message
                Text(config.message.isEmpty ? "Please expand your storage immediately." : config.message)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Primary button
                Button(action: config.onExpand) {
                    Text(config.expandButtonTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(red: 0.12, green: 0.48, blue: 0.98))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                
                // Secondary text button
                Button(action: config.onCleanUp) {
                    Text(config.cleanupButtonTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.gray.opacity(0.9))
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .frame(width: width)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)
            
            // Top icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.86, green: 0.93, blue: 1.0))
                    .frame(width: 84, height: 84)
                
                if let icon = iconImage {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 84, height: 84)
                        .clipped()
                } else {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(red: 1.0, green: 0.35, blue: 0.18))
                        .frame(width: 50, height: 50)
                }
            }
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 6)
            )
            .offset(y: -42)
        }
    }
}

// MARK: - Visual Effect Blur

/// UIKit blur effect wrapper for SwiftUI
public struct JetVisualEffectBlur: UIViewRepresentable {
    public var blurStyle: UIBlurEffect.Style
    
    public init(blurStyle: UIBlurEffect.Style = .systemMaterialDark) {
        self.blurStyle = blurStyle
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}