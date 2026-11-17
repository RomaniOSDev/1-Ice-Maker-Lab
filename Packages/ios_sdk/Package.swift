// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AdjustSdk",
    platforms: [
        .iOS(.v12),
        .tvOS(.v12)
    ],
    products: [
        .library(name: "AdjustSdk", targets: ["AdjustSdk"])
    ],
    targets: [
        .binaryTarget(
            name: "AdjustSignature",
            path: "AdjustSignature/AdjustSigSdk.xcframework"
        ),
        .target(
            name: "AdjustSdk",
            dependencies: [
                "AdjustSignature"
            ],
            path: "Adjust",
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ],
            cSettings: [
                .headerSearchPath(""),
                .headerSearchPath("Internal")
            ]
        )
    ]
)
