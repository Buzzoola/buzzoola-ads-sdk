// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BuzzoolaAdsSDK",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BuzzoolaAdsSDK",
            targets: ["BuzzoolaAdsSDK"]),
        .library(
            name: "BuzzoolaAdsSDKMyTarget",
            targets: ["BuzzoolaAdsSDKMyTarget"]),
        .library(
            name: "BuzzoolaAdsSDKYandex",
            targets: ["BuzzoolaAdsSDKYandex"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/myTargetSDK/mytarget-ios-spm", from: "5.46.1"),
        .package(
            url: "https://github.com/yandexmobile/yandex-ads-sdk-ios", from: "8.0.0")
    ],
    targets: [
         .binaryTarget(
            name: "BuzzoolaAdsSDK",
            url: "https://s-mobile-pub.buzzoola.com/buzzoola.sdk.ios.5.0.0v1.xcframework.zip",
            checksum: "33be1cf53a74d085498c2e428f223b2a2a42b24e9cb4ff60cde3657be38864d7"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKMyTarget",
            url: "https://s-mobile-pub.buzzoola.com/buzzoola.sdk.ios.mytarget.5.0.0v1.xcframework.zip",
            checksum: "a57d882dcbf2acd0bb294fe49bc5c50037179c8c74430665d41ac79c2773e14e"),
        .target(
            name: "BuzzoolaAdsSDKYandex",
            dependencies: [
                .product(name: "YandexMobileAds", package: "yandex-ads-sdk-ios")
            ],
            path: "Source/"
        )
    ]
)
