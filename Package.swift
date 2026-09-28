// swift-tools-version:6.4
import PackageDescription

let package = Package(
    name: "{{name}}",
    platforms: [
       .macOS("26.2")
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "5.0.0-beta.2"),
        // 📝 Customizable logging to the console.
        .package(url: "https://github.com/vapor/console-kit.git", from: "5.0.0-beta"),
        // 🖥️ Straightforward, type-safe argument parsing for Swift.
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.8.2"),{{#fluent}}
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.56.0"),
        // {{fluent.db.emoji}} Fluent driver for {{fluent.db.module}}.
        .package(url: "https://github.com/vapor/fluent-{{fluent.db.url}}-driver.git", from: "{{fluent.db.version}}"),{{/fluent}}
    ],
    targets: [
        .executableTarget(
            name: "{{name}}",
            dependencies: [{{#fluent}}
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "Fluent{{fluent.db.module}}Driver", package: "fluent-{{fluent.db.url}}-driver"),{{/fluent}}
                .product(name: "Vapor", package: "vapor"),
                .product(name: "ConsoleLogger", package: "console-kit"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "{{name}}Tests",
            dependencies: [
                .target(name: "{{name}}"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]
}
