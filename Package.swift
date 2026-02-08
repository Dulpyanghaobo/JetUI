// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "JetUI",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "JetUI",
            targets: ["JetUI"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "JetUI",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "JetUITests",
            dependencies: ["JetUI"]),
    ]
)
