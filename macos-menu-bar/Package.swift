// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ClashVergeAutoSwitchMenuBar",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ClashVergeAutoSwitch",
            targets: ["ClashVergeAutoSwitch"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ClashVergeAutoSwitch"
        )
    ]
)
