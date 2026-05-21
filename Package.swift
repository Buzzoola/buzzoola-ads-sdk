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
            name: "BuzzoolaAdsSDKMyTarget",
            targets: ["BuzzoolaAdsSDKMyTarget"]),
        .library(
            name: "BuzzoolaAdsSDKYandex",
            targets: ["BuzzoolaAdsSDKYandex"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/myTargetSDK/mytarget-ios-spm", from: "5.29.1"),
        .package(
            url: "https://github.com/yandexmobile/yandex-ads-sdk-ios", from: "7.18.0")
    ],
    targets: [
        .binaryTarget(
            name: "BuzzoolaAdsSDK",
            url: "https://s-mobile-pub.buzzoola.com/buzzoola.sdk.ios.4.2.0.xcframework.zip",
            checksum: "765c4b2ea3015e30f1d3c2816d2c59929235d5fbf1fee433a035ea93075a4bf2"),
        .binaryTarget(
            name: "BuzzoolaAdsSDKMyTarget",
            url: "https://s-mobile-pub.buzzoola.com/buzzoola.sdk.ios.mytarget.4.2.0.xcframework.zip",
            checksum: "1c1ec0b7d0e4c16e7b7af813bcd3295ff235291764353e6705f59f3f8437e4b8"),
        .target(
            name: "BuzzoolaAdsSDKYandex",
            dependencies: [
                .product(name: "YandexMobileAds", package: "yandex-ads-sdk-ios")
            ],
            path: "Source/"
        )
    ]
)
