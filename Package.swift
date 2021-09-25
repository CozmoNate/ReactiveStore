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
        .library(name: "Dispatcher",
                 targets: ["Dispatcher"]),
        .library(name: "ReactiveObject",
                 targets: ["ReactiveObject"]),
    ],
    targets: [
        .target(name: "Dispatcher",
                dependencies: [],
                path: "Dispatcher"),
        .target(name: "ReactiveObject",
                dependencies: [],
                path: "ReactiveObject"),
    ],
    swiftLanguageVersions: [ .v5 ]
)
