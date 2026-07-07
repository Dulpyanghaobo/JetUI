// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "JetUINetworkAuth",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "JetUINetworkAuth",
            targets: ["JetUINetworkAuth"]
        )
    ],
    dependencies: [
        .package(path: "../.."),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.2")
    ],
    targets: [
        .target(
            name: "JetUINetworkAuth",
            dependencies: [
                .product(name: "JetUI", package: "JetUI"),
                .product(name: "JetUICore", package: "JetUI"),
                "Moya",
                "KeychainAccess"
            ]
        )
    ]
)
