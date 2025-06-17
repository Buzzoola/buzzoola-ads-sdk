// swift-tools-version: 6.0
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
            url: "https://github.com/MobileTeleSystems/mts-analytics-swiftpm-ios-sdk", exact: "5.1.4"),
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
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDK_3.2.0.xcframework.zip",
            checksum: "e5d15ed486cf4fc2a4676bfae8df5aaa8357ad15a9b06feab068749ed1841636"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKMyTarget",
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDKMyTarget_3.2.0.xcframework.zip",
            checksum: "a72b3e25b4d0b75e536c26cde50ded7ff769d8c26a10b8dbd2cbea85e1dcf0c9"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKAnalytics",
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDKAnalytics_3.2.0.xcframework.zip",
            checksum: "106194d1aaf69d83995f589438aae281306b17b03f60c77ac97d0aa794700f65")
    ]
)
