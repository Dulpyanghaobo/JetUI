//
//  JetOnboardingExamples.swift
//  JetUI
//
//  Example JetOnboardingPage arrays and JetOnboardingConfiguration presets.
//

import SwiftUI

// MARK: - Page Presets

public extension JetOnboardingPage {
    static func exampleWelcome() -> JetOnboardingPage {
        JetOnboardingPage(
            systemImage: "camera.fill",
            title: "Capture Every Moment",
            subtitle: "Automatically stamp your photos with time, date, and location."
        )
    }

    static func exampleLocation() -> JetOnboardingPage {
        JetOnboardingPage(
            systemImage: "location.fill",
            title: "Know Where You Were",
            subtitle: "GPS coordinates embedded in every shot for instant proof."
        )
    }

    static func exampleCloud() -> JetOnboardingPage {
        JetOnboardingPage(
            systemImage: "icloud.fill",
            title: "Backed Up & Secure",
            subtitle: "Your photos sync automatically so they're always safe."
        )
    }
}

// MARK: - Configuration Presets

public extension JetOnboardingConfiguration {
    /// Dark accent onboarding — suited for camera / photo apps.
    static let exampleDark = JetOnboardingConfiguration(
        accentColor: Color(red: 0.15, green: 0.53, blue: 0.84),
        continueButtonText: "Continue",
        finishButtonText: "Get Started",
        showSkipButton: true,
        skipButtonText: "Skip",
        showPageIndicator: true,
        textColor: .white,
        buttonHeight: 54,
        buttonCornerRadius: 27,
        buttonHorizontalPadding: 40
    )

    /// Light accent onboarding — suited for productivity apps.
    static let exampleLight = JetOnboardingConfiguration(
        accentColor: .blue,
        continueButtonText: "Next",
        finishButtonText: "Let's Go",
        showSkipButton: false,
        textColor: .white,
        buttonHeight: 50,
        buttonCornerRadius: 14,
        buttonHorizontalPadding: 32
    )
}

// MARK: - Full Flow Preset

public enum JetOnboardingExamples {
    @MainActor
    public static var examplePages: [JetOnboardingPage] {
        [
            .exampleWelcome(),
            .exampleLocation(),
            .exampleCloud(),
        ]
    }
}
