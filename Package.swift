// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "anim",
    platforms: [
        .iOS(.v10),
    ],
    products: [
        .library(name: "anim", targets: ["anim"])
    ],
    targets: [
        .target(
            name: "anim",
            path: "src"
        )
    ]
)