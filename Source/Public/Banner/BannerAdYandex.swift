//
//  BannerAdYandex.swift
//  BuzzoolaAdsSDKYandex
//
//  Created by Коротаева Елена Сергеевна on 03.06.2024.
//

import Foundation
import BuzzoolaAdsSDK

final class BannerAdYandex: BannerAd {

    // MARK: Properties

    weak var factoryDelegate: BannerAdFactoryDelegate?

    // MARK: Private properties

    private let model: AdsMeditationItemModel

    private var bannerView: BannerYandexAdView?
    
    private var startDate: Date?

    // MARK: Initializer

    init(model: AdsMeditationItemModel) {
        self.model = model
    }

    // MARK: Functions

    func show() {
        startDate = Date()

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "request-send-from_sdk_to_adapter",
            parameters: [
                "eventCategory" : "request",
                "eventAction" : "send",
                "eventLabel" : "from_sdk_to_adapter",
                "eventValue" : "1",
                "eventContent" : "banner",
                "eventContext" : "yandex",
                "CD1" : model.placementID.description
            ]
        )

        guard
            model.mediationID != ""
        else {
            if UserDefaults.standard.bool(forKey: "adsEnableLogging") {
                print("[Ads SDK] ERROR 🍎 Banner Yandex: id is empty")
            }

            BuzzoolaAdsAnalyticsManager.shared.track(
                eventName: "response-get-from_adapter_to_sdk",
                parameters: [
                    "eventCategory" : "response",
                    "eventAction" : "get",
                    "eventLabel" : "from_adapter_to_sdk",
                    "eventValue" : "0",
                    "eventContent" : "banner",
                    "eventContext" : "yandex",
                    "buttonLocation" : (Date().timeIntervalSince(startDate!) * 1000).roundedString(),
                    "filterName": model.amount.description,
                    "bannerName": "[]",
                    "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description + "]",
                    "deliveryType": AdError.loadMediationError("Yandex: id is empty").errorDescription,
                    "CD1" : model.placementID.description
                ]
            )

            factoryDelegate?.bannerFailed(adError: .loadMediationError("Yandex: id is empty"), item: .yandex(model))

            return
        }

        bannerView = BannerYandexAdView()

        bannerView?.failedDelegate = self

        bannerView?.loadAds(request: model)
    }
}

// MARK: - BannerYandexAdViewLoaderDelegate

extension BannerAdYandex: BannerYandexAdViewLoaderDelegate {

    func bannerAdViewLoaded() {
        guard
            let bannerView = bannerView,
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
                "eventValue" : "1",
                "eventContent" : "banner",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedString(),
                "filterName": model.amount.description,
                "bannerName": "[null_null]",
                "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description + "]",
                "CD1" : model.placementID.description
            ]
        )

        factoryDelegate?.bannerViewLoaded(item: .yandex(model), view: bannerView)
    }

    func bannerAdViewFailed(adError: BuzzoolaAdsSDK.AdError) {
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
                "eventContent" : "banner",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedString(),
                "filterName": model.amount.description,
                "bannerName": "[]",
                "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description + "]",
                "deliveryType": adError.errorDescription,
                "CD1" : model.placementID.description
            ]
        )

        factoryDelegate?.bannerFailed(adError: adError, item: .yandex(model))
    }
}
