// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Vitalz",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Vitalz",
            targets: ["Vitalz"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Vitalz",
            dependencies: [],
            path: "Sources/Vitalz")
    ]
)
