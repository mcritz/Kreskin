// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Kreskin",
//    exclude: [
//        "Config",
//        "Database",
//        "Localization",
//        "Public",
//        "Resources",
//    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.2"),
        //        .package(url: "https://github.com/vapor/fluent-provider.git", majorVersion: 1),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc.4"),
        .package(url: "https://github.com/vapor/postgresql.git", from: "1.0.0-rc.2.3"),
        .package(url: "https://github.com/vapor/leaf.git", from: "1.0.0-rc.2")
    ],
    targets: [
        .target(name: "App", dependencies: ["Leaf", "Auth", "PostgreSQL", "Vapor"]),
        .target(name: "Run", dependencies: ["App"]),
    ]
)

