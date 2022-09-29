// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if os(iOS)
let excludedPaths = ["Providers/Firebase/"]
#else
let excludedPaths = ["Providers/Firebase/", "Resources", "Settings"]
#endif

let package = Package(
    name: "CrowdinSDK",
    platforms: [
        .macOS(.v10_13),
        .watchOS(.v2),
        .iOS(.v9),
        .tvOS(.v9)
    ],
    products: [
        .library(name: "CrowdinSDK", targets: ["CrowdinSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/serhii-londar/BaseAPI.git", .upToNextMajor(from: "0.2.1")),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "4.0.4"))
    ],
    targets: [
        .target(name: "CrowdinSDK",
                dependencies: ["BaseAPI", "Starscream"],
                path: "Sources/CrowdinSDK",
                exclude: excludedPaths,
                swiftSettings: [
                    .define("CrowdinSDKSPM")
                ])
    ]
)
