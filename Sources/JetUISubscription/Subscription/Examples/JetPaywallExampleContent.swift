//
//  JetPaywallExampleContent.swift
//  JetUI
//
//  Example product-side content presets for testing JetPaywall integration.
//

import SwiftUI

public extension JetPaywallContent {
    /// Example trial content that mirrors how a product app should provide copy,
    /// icons, links, and button titles through one public content model.
    static var exampleTimeProofTrial: JetPaywallContent {
        JetPaywallContent(
            brandTitle: "How Free Trial Works",
            accentColor: Color(red: 0.15, green: 0.53, blue: 0.84),
            backgroundColor: Color(red: 0.08, green: 0.10, blue: 0.16),
            continueText: "Continue",
            restoreText: "Restore",
            processingText: "Processing...",
            retryText: "Retry",
            loadFailedText: "Unable to load subscription options.",
            privacyPolicyURL: URL(string: "https://www.freeprivacypolicy.com/live/8b72931a-da59-4198-8da7-731aa13d6533"),
            termsURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"),
            privacyText: "Privacy Policy",
            termsText: "Terms & Conditions",
            benefits: [
                "Unlimited timestamps",
                "Professional camera filters",
                "All premium templates",
                "No ads"
            ],
            timelineSteps: [
                TimelineStep(
                    icon: "lock.open.fill",
                    title: "Today - Full Access",
                    subtitle: "Start capturing with every Pro feature."
                ),
                TimelineStep(
                    icon: "bell.badge.fill",
                    title: "Day 5 - Trial Reminder",
                    subtitle: "Get a reminder before the trial ends."
                ),
                TimelineStep(
                    icon: "star.circle.fill",
                    title: "Day 7 - Subscription Starts",
                    subtitle: "Keep Pro active after the free trial."
                )
            ],
            complexBenefits: [
                BenefitItem(icon: "infinity.circle.fill", title: "Unlimited timestamps"),
                BenefitItem(icon: "camera.filters", title: "Professional camera filters"),
                BenefitItem(icon: "wand.and.stars", title: "All premium templates"),
                BenefitItem(icon: "xmark.shield.fill", title: "No ads")
            ]
        )
    }

    /// Example full paywall content for the list-style layout.
    static var exampleTimeProofFull: JetPaywallContent {
        JetPaywallContent(
            brandTitle: "GPS CAM PRO",
            accentColor: Color(red: 0.15, green: 0.53, blue: 0.84),
            backgroundColor: .black,
            continueText: "Continue",
            restoreText: "Restore",
            processingText: "Processing...",
            retryText: "Retry",
            loadFailedText: "Unable to load subscription options.",
            privacyPolicyURL: URL(string: "https://www.freeprivacypolicy.com/live/8b72931a-da59-4198-8da7-731aa13d6533"),
            termsURL: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"),
            privacyText: "Privacy Policy",
            termsText: "Terms & Conditions",
            benefits: [
                "Unlimited timestamps",
                "Professional camera filters",
                "All premium templates",
                "No ads"
            ],
            highlightKeyword: "PRO"
        )
    }
}
