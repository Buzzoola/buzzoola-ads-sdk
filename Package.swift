// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuzzoolaAdsSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BuzzoolaAdsSDK",
            targets: ["BuzzoolaAdsSDK"]),
        .library(
            name: "BuzzoolaAdsSDKAnalytics",
            targets: ["BuzzoolaAdsSDKAnalytics"]),
        .library(
            name: "BuzzoolaAdsSDKMyTarget",
            targets: ["BuzzoolaAdsSDKMyTarget"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/MobileTeleSystems/mts-analytics-static-swiftpm-ios-sdk", exact: "5.1.4"),
        .package(
            url: "https://github.com/devicekit/DeviceKit.git", exact: "5.5.0"),
        .package(
            url: "https://github.com/SDWebImage/SDWebImage.git", exact: "5.20.0"),
        .package(
            url: "https://github.com/myTargetSDK/mytarget-ios-spm", exact: "5.31.1")
    ],
    targets: [
        .binaryTarget(
            name: "BuzzoolaAdsSDK",
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDK_3.3.2.xcframework.zip",
            checksum: "6488a703ea31b5ee53be9355bd1dae478060ce0fa0b6d9e74fdef5d72c1305ff"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKMyTarget",
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDKMyTarget_3.3.0.xcframework.zip",
            checksum: "07ad735635128ec04cca1f6c9fe4b31631412cf86ea24f591fccefafb06eff2e"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKAnalytics",
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDKAnalytics_3.3.0.xcframework.zip",
            checksum: "a1f3172161f6dc71126100f41710bf75b693bd0daf1abc39b69d6c69c6500e1c")
    ]
)
