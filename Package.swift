// swift-tools-version:5.6
import PackageDescription
let package = Package(
    name: "RedECS-Breakout",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14)
    ],
    products: [
        .library(
            name: "Breakout",
            targets: ["Breakout"]
        ),
        .library(
            name: "SpriteKitSupport",
            targets: ["SpriteKitSupport"]
        ),
        .executable(name: "WebSupport", targets: ["WebSupport"])
    ],
    dependencies: [
        .package(url: "https://github.com/RedECSEngine/RedECS.git", from: "0.0.3"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "0.0.1"),
        .package(url: "https://github.com/swiftwasm/JavaScriptKit", from: "0.13.0")
    ],
    targets: [
        .target(
            name: "Breakout",
            dependencies: [
                .product(name: "RedECS", package: "RedECS"),
                .product(name: "RedECSBasicComponents", package: "RedECS"),
                .product(name: "RedECSRenderingComponents", package: "RedECS"),
                .product(name: "RealModule", package: "swift-numerics")
            ]
        ),
        
        .executableTarget(
            name: "WebSupport",
            dependencies: [
                "Breakout",
                .product(name: "RedECSWebSupport", package: "RedECS"),
                .product(name: "JavaScriptKit", package: "JavaScriptKit")
            ]
        ),
        
        .target(
            name: "SpriteKitSupport",
            dependencies: [
                "Breakout",
                .product(name: "RedECSSpriteKitSupport", package: "RedECS"),
            ]
        ),
    ]
)
