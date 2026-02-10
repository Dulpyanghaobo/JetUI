//
//  JetToastView.swift
//  JetUI
//
//  Toast notification component for SwiftUI
//  Supports various toast types and global management
//
//  Migrated from TimeProof/App/UIComponent/JCToastView.swift
//

import SwiftUI
import Combine

// MARK: - Toast View

/// Toast notification view
public struct JetToastView: View {
    let message: String
    let type: ToastType
    @Binding var isPresented: Bool
    let duration: TimeInterval
    
    public init(
        message: String,
        type: ToastType = .info,
        isPresented: Binding<Bool>,
        duration: TimeInterval = 2.0
    ) {
        self.message = message
        self.type = type
        self._isPresented = isPresented
        self.duration = duration
    }
    
    public var body: some View {
        ZStack {
            Color.clear
            
            HStack(spacing: 8) {
                if let icon = type.icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(type.iconColor)
                }
                
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(type.backgroundColor)
            )
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.scale.combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - Toast Type

/// Toast notification type
public enum ToastType: Sendable {
    case success
    case error
    case warning
    case info
    
    public var icon: String? {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return nil
        }
    }
    
    public var iconColor: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .yellow
        case .info: return .white
        }
    }
    
    public var backgroundColor: Color {
        switch self {
        case .success: return Color.black.opacity(0.85)
        case .error: return Color.red.opacity(0.9)
        case .warning: return Color.orange.opacity(0.9)
        case .info: return Color.black.opacity(0.8)
        }
    }
}

// MARK: - View Modifier

/// Toast view modifier for easy attachment to any view
public struct ToastModifier: ViewModifier {
    let message: String
    let type: ToastType
    @Binding var isPresented: Bool
    let duration: TimeInterval
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                JetToastView(
                    message: message,
                    type: type,
                    isPresented: $isPresented,
                    duration: duration
                )
                .zIndex(999)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
    }
}

// MARK: - View Extension

extension View {
    /// Attach a toast notification to this view
    /// - Parameters:
    ///   - message: The message to display
    ///   - type: Toast type (success, error, warning, info)
    ///   - isPresented: Binding to control visibility
    ///   - duration: How long to show the toast (default: 2 seconds)
    public func toast(
        message: String,
        type: ToastType = .info,
        isPresented: Binding<Bool>,
        duration: TimeInterval = 2.0
    ) -> some View {
        modifier(ToastModifier(
            message: message,
            type: type,
            isPresented: isPresented,
            duration: duration
        ))
    }
    
    /// Convenience method for success toast
    public func successToast(
        message: String,
        isPresented: Binding<Bool>,
        duration: TimeInterval = 2.0
    ) -> some View {
        toast(message: message, type: .success, isPresented: isPresented, duration: duration)
    }
    
    /// Convenience method for error toast
    public func errorToast(
        message: String,
        isPresented: Binding<Bool>,
        duration: TimeInterval = 2.0
    ) -> some View {
        toast(message: message, type: .error, isPresented: isPresented, duration: duration)
    }
}

// MARK: - Toast Manager (Global)

/// Global toast manager for showing toasts from anywhere
@MainActor
public final class ToastManager: ObservableObject {
    
    public static let shared = ToastManager()
    
    @Published public var isPresented: Bool = false
    @Published public var message: String = ""
    @Published public var type: ToastType = .info
    @Published public var duration: TimeInterval = 2.0
    
    private var dismissTask: Task<Void, Never>?
    
    private init() {}
    
    /// Show a toast notification
    /// - Parameters:
    ///   - message: Message to display
    ///   - type: Toast type
    ///   - duration: Display duration in seconds
    public func show(
        message: String,
        type: ToastType = .info,
        duration: TimeInterval = 2.0
    ) {
        // Cancel any pending dismiss
        dismissTask?.cancel()
        
        self.message = message
        self.type = type
        self.duration = duration
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            self.isPresented = true
        }
        
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.3)) {
                    self.isPresented = false
                }
            }
        }
    }
    
    /// Show success toast
    public func success(_ message: String, duration: TimeInterval = 2.0) {
        show(message: message, type: .success, duration: duration)
    }
    
    /// Show error toast
    public func error(_ message: String, duration: TimeInterval = 2.5) {
        show(message: message, type: .error, duration: duration)
    }
    
    /// Show warning toast
    public func warning(_ message: String, duration: TimeInterval = 2.0) {
        show(message: message, type: .warning, duration: duration)
    }
    
    /// Show info toast
    public func info(_ message: String, duration: TimeInterval = 2.0) {
        show(message: message, type: .info, duration: duration)
    }
    
    /// Dismiss current toast
    public func dismiss() {
        dismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            isPresented = false
        }
    }
}

// MARK: - Global Toast Container

/// Container view that displays global toasts
/// Add this to your root view to enable global toast notifications
public struct GlobalToastContainer<Content: View>: View {
    @StateObject private var toastManager = ToastManager.shared
    let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            content
            
            if toastManager.isPresented {
                VStack {
                    Spacer()
                    
                    JetToastView(
                        message: toastManager.message,
                        type: toastManager.type,
                        isPresented: $toastManager.isPresented,
                        duration: toastManager.duration
                    )
                    .padding(.bottom, 100)
                }
                .zIndex(9999)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct JetToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            JetToastView(
                message: "Success message",
                type: .success,
                isPresented: .constant(true)
            )
            
            JetToastView(
                message: "Error message",
                type: .error,
                isPresented: .constant(true)
            )
            
            JetToastView(
                message: "Warning message",
                type: .warning,
                isPresented: .constant(true)
            )
            
            JetToastView(
                message: "Info message",
                type: .info,
                isPresented: .constant(true)
            )
        }
        .padding()
    }
}
#endif