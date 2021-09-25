// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReactiveStore",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_14),
        .watchOS(.v5),
        .tvOS(.v12)
    ],
    products: [
        .library(name: "Dispatcher",
                 targets: ["Dispatcher"]),
        .library(name: "ReactiveStore",
                 targets: ["ReactiveStore"]),
    ],
    targets: [
        .target(name: "Dispatcher",
                dependencies: [],
                path: "Dispatcher"),
        .target(name: "ReactiveStore",
                dependencies: [],
                path: "ReactiveStore"),
    ],
    swiftLanguageVersions: [ .v5 ]
)
