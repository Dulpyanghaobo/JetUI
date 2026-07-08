// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "JetUIFirebaseAdapters",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "JetUIFirebaseAdapters",
            targets: ["JetUIFirebaseAdapters"]
        )
    ],
    dependencies: [
        .package(path: "../.."),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
    ],
    targets: [
        .target(
            name: "JetUIFirebaseAdapters",
            dependencies: [
                .product(name: "JetUI", package: "JetUI"),
                .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk")
            ]
        ),
        .testTarget(
            name: "JetUIFirebaseAdaptersTests",
            dependencies: [
                "JetUIFirebaseAdapters"
            ]
        )
    ]
)
