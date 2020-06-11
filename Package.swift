// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "anim",
    platforms: [.iOS(.v8), .macOS(.v10_10), .tvOS(.v9)],
    products: [
        .library(
            name: "anim",
            targets: ["anim"])
    ],
    targets: [
        .target(
            name: "anim",
            path: "anim/anim",
            publicHeadersPath: ".")
    ]
)
