// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "flutter_contacts",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "flutter-contacts", targets: ["flutter_contacts"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "flutter_contacts",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
