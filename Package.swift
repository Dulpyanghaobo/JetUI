// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JetUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "JetUI",
            targets: ["JetUI"]),
        .library(
            name: "JetUICore",
            targets: ["JetUICore"]),
        .library(
            name: "JetUIDesign",
            targets: ["JetUIDesign"]),
        .library(
            name: "JetUIComponents",
            targets: ["JetUIComponents"]),
        .library(
            name: "JetUISettings",
            targets: ["JetUISettings"]),
        .library(
            name: "JetUISubscription",
            targets: ["JetUISubscription"]),
        .library(
            name: "JetUIAnalytics",
            targets: ["JetUIAnalytics"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "JetUICore"
        ),
        .target(
            name: "JetUIDesign",
            exclude: [
                "Theme/Theme_README.md"
            ]
        ),
        .target(
            name: "JetUIAnalytics"
        ),
        .target(
            name: "JetUIComponents",
            dependencies: [
                "JetUIDesign"
            ]
        ),
        .target(
            name: "JetUISettings",
            exclude: [
                "Settings/README.md"
            ],
            resources: [
                .process("Resources/Media.xcassets")
            ]
        ),
        .target(
            name: "JetUISubscription",
            dependencies: [
                "JetUICore",
                "JetUIAnalytics"
            ],
            exclude: [
                "Subscription/Subscription_README.md"
            ],
            resources: [
                .process("Subscription/Resources")
            ]
        ),
        .target(
            name: "JetUI",
            dependencies: [
                "JetUICore",
                "JetUIDesign",
                "JetUIAnalytics",
                "JetUIComponents",
                "JetUISettings",
                "JetUISubscription"
            ]
        ),
        .testTarget(
            name: "JetUITests",
            dependencies: ["JetUI"]),
    ]
)
