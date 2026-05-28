// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "contacts-bridge",
    platforms: [
        .iOS("12.0"),
        .macOS("10.14")
    ],
    products: [
        .library(name: "contacts-bridge", targets: ["contacts-bridge"])
    ],
    targets: [
        .target(
            name: "contacts-bridge",
            path: "Sources/contacts_bridge",
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
