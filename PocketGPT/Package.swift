// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PocketGPT",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .iOSApplication(
            name: "PocketGPT",
            targets: ["PocketGPT"],
            bundleIdentifier: "app.pocketgpt.client",
            teamIdentifier: "TEAMID",
            displayVersion: "0.1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "PocketGPT",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PocketGPTTests",
            dependencies: ["PocketGPT"],
            path: "Tests"
        )
    ]
)
