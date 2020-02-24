// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "{{name}}",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta"){{#fluent}},
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-beta"),
        .package(url: "https://github.com/vapor/fluent-{{fluent.db.url}}-driver.git", from: "{{fluent.db.version}}-beta"){{/fluent}}
    ],
    targets: [
        .target(name: "App", dependencies: [{{#fluent}}
            "Fluent", 
            "Fluent{{fluent.db.module}}Driver",{{/fluent}}
            "Vapor"
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "XCTVapor"])
    ]
)
