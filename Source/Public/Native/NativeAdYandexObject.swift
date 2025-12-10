//
//  NativeAdYandexObject.swift
//  BuzzoolaAdsSDKYandex
//
//  Created by Коротаева Елена Сергеевна on 14.10.2024.
//

import Foundation
import YandexMobileAds
import BuzzoolaAdsSDK

final class NativeAdYandexObject: BaseNativeAdObject, NativeAdObject {

    // MARK: Private properties

    private let model: AdsMeditationItemModel

    var ads = [BuzzoolaAdsSDK.NativeAd]()

    private lazy var adLoader: NativeBulkAdLoader = {
        let adLoader = NativeBulkAdLoader()
        adLoader.delegate = self
        return adLoader
    }()

    private var startDate: Date?

    // MARK: Initializer

    init(model: AdsMeditationItemModel) {
        self.model = model
    }

    // MARK: Functions

    func loadAd() {
        startDate = Date()

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "request-send-from_sdk_to_adapter",
            parameters: [
                "eventCategory" : "request",
                "eventAction" : "send",
                "eventLabel" : "from_sdk_to_adapter",
                "eventValue" : model.amount.description,
                "eventContent" : "native",
                "eventContext" : "yandex",
                "CD1" : model.placementID.description
            ]
        )

        guard
            model.mediationID != ""
        else {
            if UserDefaults.standard.bool(forKey: "adsEnableLogging") {
                print("[Ads SDK] ERROR 🍎 Native Yandex: id is empty")
            }

            BuzzoolaAdsAnalyticsManager.shared.track(
                eventName: "response-get-from_adapter_to_sdk",
                parameters: [
                    "eventCategory" : "response",
                    "eventAction" : "get",
                    "eventLabel" : "from_adapter_to_sdk",
                    "eventValue" : "0",
                    "eventContent" : "native",
                    "eventContext" : "yandex",
                    "buttonLocation" : (Date().timeIntervalSince(startDate!) * 1000).roundedString(),
                    "filterName": model.amount.description,
                    "bannerName": "[]",
                    "bannerID": "[]",
                    "deliveryType": AdError.loadMediationError("Yandex: id is empty").errorDescription,
                    "CD1" : model.placementID.description
                ]
            )

            factoryDelegate?.onAdNativeFailed(
                error: .loadMediationError("Yandex: id is empty"),
                item: .yandex(model))
            return
        }
        
        let requestConfiguration = MutableNativeAdRequestConfiguration(adUnitID: model.mediationID)

        requestConfiguration.adTheme = model.isDarkMode ? .dark : .light
        requestConfiguration.age = model.age as? NSNumber
        requestConfiguration.gender = model.gender?.rawValue

        adLoader.loadAds(with: requestConfiguration, adsCount: model.amount)
    }
}

// MARK: - YMANativeAdLoaderDelegate

extension NativeAdYandexObject: NativeBulkAdLoaderDelegate {

    func nativeBulkAdLoader(_ nativeBulkAdLoader: YandexMobileAds.NativeBulkAdLoader, didLoad ads: [any YandexMobileAds.NativeAd]) {
        var listBannerName = [String]()
        var listBannerID = [String]()
        var listPaymentType = [String]()

        ads.enumerated().forEach { number, ad in
            model.index = number + 1
            let adItem = NativeAdYandex(model: model, ad: ad)
            self.ads.append(adItem)

            let bannerName = (ad.adAssets().domain ?? "null") + "_" + (ad.adAssets().title ?? "null")
            listBannerName.append(bannerName)

            let bannerID = "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description
            listBannerID.append(bannerID)

            listPaymentType.append(ad.adAssets().price ?? "null")
        }

        guard
            let startDate = startDate
        else {
            return
        }

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "response-get-from_adapter_to_sdk",
            parameters: [
                "eventCategory" : "response",
                "eventAction" : "get",
                "eventLabel" : "from_adapter_to_sdk",
                "eventValue" : ads.count.description,
                "eventContent" : "native",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedString(),
                "filterName": model.amount.description,
                "bannerName": "[" + listBannerName.joined(separator: ", ") + "]",
                "bannerID": "[" + listBannerID.joined(separator: ", ") + "]",
                "CD1" : model.placementID.description
            ]
        )

        factoryDelegate?.onAdLoaded(ad: self, item: .yandex(model))
    }

    func nativeBulkAdLoader(_ nativeBulkAdLoader: YandexMobileAds.NativeBulkAdLoader, didFailLoadingWithError error: any Error) {
        guard
            let startDate = startDate
        else {
            return
        }

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "response-get-from_adapter_to_sdk",
            parameters: [
                "eventCategory" : "response",
                "eventAction" : "get",
                "eventLabel" : "from_adapter_to_sdk",
                "eventValue" : "0",
                "eventContent" : "native",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedString(),
                "filterName": model.amount.description,
                "bannerName": "[]",
                "bannerID": "[]",
                "deliveryType": error.localizedDescription,
                "CD1" : model.placementID.description
            ]
        )
        
        factoryDelegate?.onAdNativeFailed(
            error: AdError.loadMediationError(error.localizedDescription),
            item: .yandex(model))
    }
}
