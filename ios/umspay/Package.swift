// swift-tools-version: 5.9

import Foundation
import PackageDescription

let packageDirectory = URL(fileURLWithPath: #filePath).deletingLastPathComponent().path

let package = Package(
    name: "umspay",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "umspay", targets: ["umspay"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "umspay",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "AlipaySDK",
                "WechatOpenSDK",
                "UMSPosPayOnlyShim",
            ],
            path: "Sources/umspay",
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            swiftSettings: [
                .define("UMSPAY_SPM"),
            ],
            linkerSettings: [
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("CoreTelephony"),
                .linkedFramework("QuartzCore"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CFNetwork"),
                .linkedFramework("CoreMotion"),
                .linkedFramework("WebKit"),
                .linkedLibrary("z"),
                .linkedLibrary("c++"),
            ]
        ),
        .target(
            name: "UMSPosPayOnlyShim",
            dependencies: [
                "AlipaySDK",
                "WechatOpenSDK",
                "UPPaymentControlMini",
            ],
            path: "Sources/UMSPosPayOnlyShim",
            publicHeadersPath: "include",
            linkerSettings: [
                .unsafeFlags(
                    [
                        "\(packageDirectory)/../Classes/UMSPosPayOnly/libUMSPosPayOnly.a",
                        "-ObjC",
                        "-all_load",
                    ],
                    .when(platforms: [.iOS])
                ),
            ]
        ),
        .binaryTarget(
            name: "AlipaySDK",
            path: "Binaries/AlipaySDK.xcframework"
        ),
        .binaryTarget(
            name: "WechatOpenSDK",
            path: "Binaries/WechatOpenSDK.xcframework"
        ),
        .binaryTarget(
            name: "UPPaymentControlMini",
            path: "Binaries/UPPaymentControlMini.xcframework"
        ),
    ]
)
