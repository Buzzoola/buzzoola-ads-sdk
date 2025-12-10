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
            targets: ["BuzzoolaAdsSDKMyTarget"]),
        .library(
            name: "BuzzoolaAdsSDKYandex",
            targets: ["BuzzoolaAdsSDKYandex"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/MobileTeleSystems/mts-analytics-static-swiftpm-ios-sdk", exact: "5.1.4"),
        .package(
            url: "https://github.com/devicekit/DeviceKit.git", from: "5.5.0"),
        .package(
            url: "https://github.com/myTargetSDK/mytarget-ios-spm", from: "5.29.1"),
        .package(
            url: "https://github.com/yandexmobile/yandex-ads-sdk-ios", from: "7.18.0")
    ],
    targets: [
        .binaryTarget(
            name: "BuzzoolaAdsSDK",
            url: "https://s-mobile-pub.buzzoola.com/buzzoola.sdk.ios.4.0.0.xcframework.zip",
            checksum: "5607f44ccfd3f3f05591509a5327ab1a4732ae9f1239ec30c0ebbf7fb2f53302"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKMyTarget",
            url: "https://s-mobile-pub.buzzoola.com/buzzoola.sdk.ios.mytarget.4.0.0.xcframework.zip",
            checksum: "d2289ca914c51a1f8ef9145a7916a0207850dc39147f36bbac7d637a70c3377a"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKAnalytics",
            url: "https://ru-msk-1.store.cloud.mts.ru/monetization.download/repository/ios-sdk/BuzzoolaAdsSDKAnalytics_3.3.0.xcframework.zip",
            checksum: "a1f3172161f6dc71126100f41710bf75b693bd0daf1abc39b69d6c69c6500e1c"),
        .target(
            name: "BuzzoolaAdsSDKYandex",
            dependencies: [
                .product(name: "YandexMobileAds", package: "yandex-ads-sdk-ios")
            ],
            path: "Source/"
        )
    ]
)
