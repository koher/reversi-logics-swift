// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReversiLogics",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ReversiLogics",
            targets: ["UseCases", "Presenters"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "SwiftyReversi", url: "https://github.com/koher/swifty-reversi.git", from: "0.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "UseCases",
            dependencies: ["SwiftyReversi"]),
        .target(
            name: "Presenters",
            dependencies: ["UseCases", "SwiftyReversi"]),
        .testTarget(
            name: "UseCasesTests",
            dependencies: ["UseCases", "SwiftyReversi"]),
        .testTarget(
            name: "PresentersTests",
            dependencies: ["Presenters", "UseCases", "SwiftyReversi"]),
    ]
)
