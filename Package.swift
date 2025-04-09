// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CrowdinSDK",
    platforms: [
        .macOS(.v10_13),
        .watchOS(.v5),
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        .library(name: "CrowdinSDK", targets: ["CrowdinSDK"]),
        .library(name: "CrowdinXCTestScreenshots", targets: ["CrowdinXCTestScreenshots"])
    ],
    dependencies: [
        .package(url: "https://github.com/serhii-londar/BaseAPI.git", .upToNextMajor(from: "0.2.1")),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "4.0.4")),
    ],
    targets: [
        .target(
            name: "CrowdinXCTestScreenshots",
            dependencies: ["CrowdinSDK"],
            path: "Sources/CrowdinSDK/Features/XCTestScreenshotFeature",
            swiftSettings: [
                .define("CrowdinSDKSPM")
            ]
        ),
        .target(
            name: "CrowdinSDK",
            dependencies: ["BaseAPI", "Starscream"],
            path: "Sources/CrowdinSDK",
            exclude: ["Features/XCTestScreenshotFeature"],
            swiftSettings: [
                .define("CrowdinSDKSPM")
            ]
        )
    ]
)
