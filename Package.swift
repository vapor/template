// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.2"){{#fluent}},
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha.2"),
        .package(url: "https://github.com/vapor/fluent-{{lowercase(fluent.db)}}-driver.git", from: "4.0.0-alpha.3"){{/fluent}}
    ],
    targets: [
        .target(name: "App", dependencies: [{{#fluent}}"Fluent", "Fluent{{fluent.db}}Driver", {{/fluent}}"Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
