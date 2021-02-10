// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReactiveStore",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .watchOS(.v4),
        .tvOS(.v10)
    ],
    products: [
        .library(name: "ActionDispatcher",
                 targets: ["ActionDispatcher"]),
        .library(name: "ReactiveStore",
                 targets: ["ReactiveStore"]),
    ],
    targets: [
        .target(name: "ActionDispatcher",
                dependencies: [],
                path: "ActionDispatcher"),
        .target(name: "ReactiveStore",
                dependencies: [],
                path: "ReactiveStore"),
    ],
    swiftLanguageVersions: [ .v5 ]
)
