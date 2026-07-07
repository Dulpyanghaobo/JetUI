//
//  JetExtensionExamples.swift
//  JetUI
//
//  Example configurations for JetUI View and UIImage extensions.
//

import SwiftUI

// MARK: - Back Arrow Config Examples

public extension JetBackArrowConfig {
    static let exampleBlue = JetBackArrowConfig(
        iconSystemName: "arrow.left",
        iconColor: .white,
        backgroundColor: Color(red: 0.15, green: 0.53, blue: 0.84)
    )

    static let exampleTransparent = JetBackArrowConfig(
        iconSystemName: "chevron.left",
        iconColor: .white,
        backgroundColor: .clear
    )
}

// MARK: - Extension Usage Snippets (structured docs for example app)

public enum JetExtensionExamples {
    public struct Snippet {
        public let title: String
        public let description: String
        public let code: String

        public init(title: String, description: String, code: String) {
            self.title = title
            self.description = description
            self.code = code
        }
    }

    public static let viewSnippets: [Snippet] = [
        Snippet(
            title: "jet_backArrow",
            description: "Replaces the default navigation back button with a unified style.",
            code: "MyView().jet_backArrow(.dark)"
        ),
        Snippet(
            title: "jet_if",
            description: "Conditionally applies a SwiftUI modifier without extra @ViewBuilder workarounds.",
            code: "Text(\"Hello\").jet_if(isPro) { $0.bold() }"
        ),
        Snippet(
            title: "jet_ifLet",
            description: "Applies a modifier only when an optional value is non-nil.",
            code: "Text(\"Hi\").jet_ifLet(badge) { view, b in view.badge(b) }"
        ),
        Snippet(
            title: "jet_fillMaxWidth",
            description: "Expands view to fill available horizontal space.",
            code: "Button(\"Submit\") {}.jet_fillMaxWidth()"
        ),
        Snippet(
            title: "jet_border",
            description: "Adds a rounded border without clipping subviews.",
            code: "card.jet_border(.blue, cornerRadius: 12)"
        ),
        Snippet(
            title: "jet_cardShadow",
            description: "Applies a consistent card-lift shadow.",
            code: "card.jet_cardShadow()"
        ),
        Snippet(
            title: "jet_hideKeyboardOnTap",
            description: "Dismisses the keyboard when the user taps outside a text field.",
            code: "Form { ... }.jet_hideKeyboardOnTap()"
        ),
    ]

    public static let imageSnippets: [Snippet] = [
        Snippet(
            title: "cropToSquare",
            description: "Crops UIImage to a centered square — useful before upload or thumbnail generation.",
            code: "let square = image.cropToSquare()"
        ),
        Snippet(
            title: "resized(to:)",
            description: "Scales UIImage to a target size while preserving proportions.",
            code: "let thumb = image.resized(to: CGSize(width: 200, height: 200))"
        ),
        Snippet(
            title: "tinted(with:)",
            description: "Applies a color tint to a template-rendered UIImage.",
            code: "let tinted = icon.tinted(with: .systemBlue)"
        ),
        Snippet(
            title: "compressed(quality:)",
            description: "Returns JPEG data at the given quality for upload or caching.",
            code: "let data = image.compressed(quality: 0.8)"
        ),
    ]
}
