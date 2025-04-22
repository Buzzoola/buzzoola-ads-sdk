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
            url: "https://github.com/MobileTeleSystems/mts-analytics-swiftpm-ios-sdk", exact: "5.0.0"),
        .package(
            url: "https://github.com/devicekit/DeviceKit.git", exact: "5.5.0"),
        .package(
            url: "https://github.com/SDWebImage/SDWebImage.git", exact: "5.20.0"),
        .package(
            url: "https://github.com/myTargetSDK/mytarget-ios-spm", exact: "5.29.1")
    ],
    targets: [
        .binaryTarget(
            name: "BuzzoolaAdsSDK",
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDK_3.1.1.xcframework.zip",
            checksum: "c01d2e943734323a68b36356c2f818597b663b000a80784ad4d6d4818d99c7f0"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKMyTarget",
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDKMyTarget_3.1.1.xcframework.zip",
            checksum: "425045376f769205f5d918e4a93b6be49685bd0499278f37ce1899e151837de3"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKAnalytics",
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDKAnalytics_3.1.1.xcframework.zip",
            checksum: "106f7564ee55cc1ce3403332d2ebbb1c367707b0cacc4c9af1bec33b2b729ca3")
    ]
)
