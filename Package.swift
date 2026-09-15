// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftGoogleSignIn",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SwiftGoogleSignIn", targets: ["SwiftGoogleSignIn"])
    ],
    dependencies: [
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "8.0.0")
    ],
    targets: [
        .target(
            name: "SwiftGoogleSignIn",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleSignInSwift", package: "GoogleSignIn-iOS")
            ]
        ),
        .testTarget(
            name: "SwiftGoogleSignInTests",
            dependencies: ["SwiftGoogleSignIn"]
        )
    ]
)
