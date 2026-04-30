// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Vitalz",
    platforms: [
        .iOS(.v15)
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
