// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "{{name}}",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc"){{#fluent}},
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc"),
        .package(url: "https://github.com/vapor/fluent-{{fluent.db.url}}-driver.git", from: "{{fluent.db.version}}-rc"){{/fluent}}
    ],
    targets: [
        .target(name: "App", dependencies: [{{#fluent}}
            .product(name: "Fluent", package: "fluent"),
            .product(name: "Fluent{{fluent.db.module}}Driver", package: "fluent-{{fluent.db.url}}-driver"),{{/fluent}}
            .product(name: "Vapor", package: "vapor")
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
