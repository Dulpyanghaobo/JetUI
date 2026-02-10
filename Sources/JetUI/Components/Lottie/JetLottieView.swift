//
//  JetLottieView.swift
//  JetUI
//
//  Lottie animation wrapper for SwiftUI
//

import SwiftUI
import Lottie

// MARK: - JetLottieView

/// A SwiftUI wrapper for Lottie animations
/// Supports both .lottie and .json animation files
public struct JetLottieView: UIViewRepresentable {
    
    /// Animation file name (without extension)
    public var filename: String
    
    /// Animation loop mode
    public var loopMode: LottieLoopMode
    
    /// Animation speed (1.0 is normal)
    public var animationSpeed: CGFloat
    
    /// Content mode for the animation
    public var contentMode: UIView.ContentMode
    
    /// Whether to auto-play when view appears
    public var autoPlay: Bool
    
    /// Bundle to load the animation from
    public var bundle: Bundle
    
    /// Initialize a Lottie animation view
    /// - Parameters:
    ///   - filename: Animation file name (without extension)
    ///   - loopMode: Loop mode (default: .loop)
    ///   - animationSpeed: Animation speed (default: 1.0)
    ///   - contentMode: Content mode (default: .scaleAspectFit)
    ///   - autoPlay: Auto-play on appear (default: true)
    ///   - bundle: Bundle to load from (default: .main)
    public init(
        filename: String,
        loopMode: LottieLoopMode = .loop,
        animationSpeed: CGFloat = 1.0,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        autoPlay: Bool = true,
        bundle: Bundle = .main
    ) {
        self.filename = filename
        self.loopMode = loopMode
        self.animationSpeed = animationSpeed
        self.contentMode = contentMode
        self.autoPlay = autoPlay
        self.bundle = bundle
    }
    
    public func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        
        // Try to load animation from different file formats
        var animation: LottieAnimation? = nil
        
        // Try .lottie format first
        if let lottiePath = bundle.path(forResource: filename, ofType: "lottie") {
            animation = LottieAnimation.filepath(lottiePath)
        }
        // Then try .json format
        else if let jsonPath = bundle.path(forResource: filename, ofType: "json") {
            animation = LottieAnimation.filepath(jsonPath)
        }
        // Log warning if not found
        else {
            print("⚠️ JetLottieView: Animation file not found: \(filename)")
        }
        
        let animationView = LottieAnimationView(animation: animation)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.contentMode = contentMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        if autoPlay {
            animationView.play()
        }
        
        containerView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Store reference for coordinator
        context.coordinator.animationView = animationView
        
        return containerView
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.animationView?.loopMode = loopMode
        context.coordinator.animationView?.animationSpeed = animationSpeed
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    // MARK: - Coordinator
    
    public class Coordinator {
        var animationView: LottieAnimationView?
    }
}

// MARK: - Convenience Initializers

public extension JetLottieView {
    
    /// Create a one-shot animation (plays once)
    static func oneShot(
        filename: String,
        animationSpeed: CGFloat = 1.0,
        bundle: Bundle = .main
    ) -> JetLottieView {
        JetLottieView(
            filename: filename,
            loopMode: .playOnce,
            animationSpeed: animationSpeed,
            bundle: bundle
        )
    }
    
    /// Create a looping animation
    static func loop(
        filename: String,
        animationSpeed: CGFloat = 1.0,
        bundle: Bundle = .main
    ) -> JetLottieView {
        JetLottieView(
            filename: filename,
            loopMode: .loop,
            animationSpeed: animationSpeed,
            bundle: bundle
        )
    }
    
    /// Create an auto-reverse animation
    static func autoReverse(
        filename: String,
        animationSpeed: CGFloat = 1.0,
        bundle: Bundle = .main
    ) -> JetLottieView {
        JetLottieView(
            filename: filename,
            loopMode: .autoReverse,
            animationSpeed: animationSpeed,
            bundle: bundle
        )
    }
}

// MARK: - View Extension

public extension View {
    
    /// Overlay a Lottie animation on the view
    /// - Parameters:
    ///   - filename: Animation file name
    ///   - loopMode: Loop mode
    ///   - isPresented: Binding to control visibility
    /// - Returns: View with animation overlay
    func lottieOverlay(
        filename: String,
        loopMode: LottieLoopMode = .playOnce,
        isPresented: Binding<Bool>
    ) -> some View {
        self.overlay(
            Group {
                if isPresented.wrappedValue {
                    JetLottieView(filename: filename, loopMode: loopMode)
                }
            }
        )
    }
}

// MARK: - Preview

#if DEBUG
struct JetLottieView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Example with placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 200, height: 200)
                .overlay(
                    Text("Lottie Animation")
                        .foregroundColor(.gray)
                )
        }
    }
}
#endif