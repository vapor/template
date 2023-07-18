// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "{{name}}",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.77.1"),{{#fluent}}
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
        // {{fluent.db.emoji}} Fluent driver for {{fluent.db.module}}.
        .package(url: "https://github.com/vapor/fluent-{{fluent.db.url}}-driver.git", from: "{{fluent.db.version}}"),{{/fluent}}{{#leaf}}
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "4.2.4"),{{/leaf}}
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [{{#fluent}}
                .product(name: "Fluent", package: "fluent"),
                .product(name: "Fluent{{fluent.db.module}}Driver", package: "fluent-{{fluent.db.url}}-driver"),{{/fluent}}{{#leaf}}
                .product(name: "Leaf", package: "leaf"),{{/leaf}}
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
