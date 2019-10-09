// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "#(name)",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        #if(fluent):
        .package(url: "https://github.com/vapor/fluent-#lowercased(fluentdb).git", from: "#(fluentversion)"),
        #endif 
        #if(leaf):
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        #endif
    ],
    targets: [
        .target(name: "App", dependencies: [
            "Vapor",
            #if(fluent):
            "Fluent#(fluentdb)",#endif #if(leaf):
            "Leaf",
            #endif
        ]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
