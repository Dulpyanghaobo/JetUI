// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JetUI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "JetUI",
            targets: ["JetUI"]),
    ],
    dependencies: [
        // Moya for type-safe networking
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        // KeychainAccess for secure token storage
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2"),
        // Lottie for animations
        .package(url: "https://github.com/airbnb/lottie-ios.git", from: "4.4.0"),
        // Firebase SDK for analytics
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "JetUI",
            dependencies: [
                "Moya",
                "KeychainAccess",
                .product(name: "Lottie", package: "lottie-ios"),
                // Firebase products
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk")
            ],
            exclude: [
                "Features/Settings/README.md"
            ],
            resources: [
                .process("Resources/Media.xcassets"),
                // Subscription module localization resources
                .process("Features/Subscription/Resources")
            ]
        ),
        .testTarget(
            name: "JetUITests",
            dependencies: ["JetUI"]),
    ]
)
