// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "zego_uikit",
    platforms: [.iOS("14.0")],
    products: [.library(name: "zego-uikit", targets: ["zego_uikit"])],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(name: "zego_express_engine_for_uikit", path: "../zego_express_engine_for_uikit")
    ],
    targets: [
        .target(
            name: "zego_uikit",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "zego-express-engine-for-uikit", package: "zego_express_engine_for_uikit"),
                "ZegoUIKitReport",
                "ZegoConnection"
            ],
            cSettings: [
                .headerSearchPath("include/zego_uikit"),
                .define("SWIFT_PACKAGE")
            ]
        ),
        .binaryTarget(
            name: "ZegoUIKitReport",
            url: "https://raw.githubusercontent.com/yoer/uikit_spm_report/f06fe254223542c6d0604bf0bd7a738f482d4646/ZegoUIKitReport.xcframework.zip",
            checksum: "f2dcab273c926d0d6650aac303d84be478b596a090a162dce50d6f989fd95547"
        ),
        .binaryTarget(
            name: "ZegoConnection",
            url: "https://raw.githubusercontent.com/yoer/uikit_spm_connection/0f485461b3dcf2a0c9b0b77f2f8f1b1ed64cd986/ZegoConnection.xcframework.zip",
            checksum: "5d13e18b757c133a805a47fa418a87406d7648f3b3f9a6b1437ebcbea8c5905c"
        ),
    ]
)
