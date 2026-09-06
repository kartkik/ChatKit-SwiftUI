// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ChatKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ChatKit",
            targets: ["ChatKit"]
        ),
    ],
    targets: [
        .target(
            name: "ChatKit",
            path: "Sources/ChatKit"
        ),
        .testTarget(
            name: "ChatKitTests",
            dependencies: ["ChatKit"],
            path: "Tests/ChatKitTests"
        ),
    ]
)
