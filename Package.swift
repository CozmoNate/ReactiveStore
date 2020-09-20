// swift-tools-version:5.1
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
        .library(name: "ReactiveStore",
                 targets: ["ReactiveStore"]),
        .library(name: "ReactiveStoreObserving",
                 targets: ["ReactiveStoreObserving"]),
    ],
    targets: [
        .target(name: "ReactiveStore",
                dependencies: [],
                path: "ReactiveStore"),
        .target(name: "ReactiveStoreObserving",
                dependencies: ["ReactiveStore"],
                path: "ReactiveStoreObserving"),
    ],
    swiftLanguageVersions: [ .v5 ]
)
