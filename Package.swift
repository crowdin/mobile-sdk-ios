// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CrowdinSDK",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "CrowdinSDK", targets: ["CrowdinSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/serhii-londar/BaseAPI.git", .upToNextMajor(from: "0.2.1")),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.1.0"))
    ],
    targets: [
        .target(name: "CrowdinSDK",
                dependencies: ["BaseAPI", "Starscream"],
                path: "CrowdinSDK/Classes",
                exclude: [
                    "Providers/Firebase/"
                ],
                resources: [.copy("Assets/SettingsView.xib")])
    ]
)
