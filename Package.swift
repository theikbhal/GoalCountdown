// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "GoalCountdown",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "GoalCountdown",
            path: "Sources/GoalCountdown",
            resources: [
                .copy("../../Resources")
            ]
        )
    ]
)
