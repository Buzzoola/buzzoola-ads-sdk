//
//  AppOpenAdYandex.swift
//  BuzzoolaAdsSDK
//
//  Created by Коротаева Елена Сергеевна on 23.12.2025.
//

import Foundation
import YandexMobileAds
import BuzzoolaAdsSDK

final class AppOpenAdYandex: BaseAppOpenAd, BuzzoolaAdsSDK.AppOpenAd {

    // MARK: Properties

    weak var factoryDelegate: AppOpenAdFactoryDelegate?

    // MARK: Private properties

    private let model: AdsMeditationItemModel

    private lazy var adLoader: YandexMobileAds.AppOpenAdLoader = {
        let adLoader = YandexMobileAds.AppOpenAdLoader()
        adLoader.delegate = self
        return adLoader
    }()

    private var appOpenAd: YandexMobileAds.AppOpenAd?

    private var startDate: Date?

    private var isFirstEventClick = true

    private var impressionData: String?

    private var isImpression = false

    private var isLoaded = false

    private var isFailed = false

    // MARK: Initializer

    init(model: AdsMeditationItemModel) {
        self.model = model
    }

    deinit {
        guard
            !isFailed
        else {
            return
        }

        var impressionLocalError: ImpressionError?

        if !isLoaded {
            impressionLocalError = .notStarted
        } else if !isImpression {
            impressionLocalError = .unknownReason
        }

        if let impressionLocalError = impressionLocalError {
            BuzzoolaAdsAnalyticsManager.shared.track(
                eventName: "ad-impression_error-in_app",
                parameters: [
                    "eventCategory" : "ad",
                    "eventAction" : "impression_error",
                    "eventLabel" : "in_app",
                    "eventContent" : "appopen",
                    "eventContext" : "yandex",
                    "filterName": impressionLocalError.filterName,
                    "bannerName" : impressionLocalError.bannerName,
                    "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                    "CD1" : model.placementID.description
                ])
        }
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
                "eventValue" : "1",
                "eventContent" : "interstitial",
                "eventContext" : "yandex",
                "CD1" : model.placementID.description
            ]
        )

        guard
            model.mediationID != ""
        else {
            isFailed = true

            if UserDefaults.standard.bool(forKey: "adsEnableLogging") {
                print("[Ads SDK] ERROR 🍎 AppOpenAd Yandex: id is empty")
            }

            BuzzoolaAdsAnalyticsManager.shared.track(
                eventName: "response-get-from_adapter_to_sdk",
                parameters: [
                    "eventCategory" : "response",
                    "eventAction" : "get",
                    "eventLabel" : "from_adapter_to_sdk",
                    "eventValue" : "0",
                    "eventContent" : "appopen",
                    "eventContext" : "yandex",
                    "buttonLocation" : (Date().timeIntervalSince(startDate!) * 1000).roundedStringBuzzoola(),
                    "filterName": model.amount.description,
                    "bannerName": "[]",
                    "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description + "]",
                    "deliveryType": AdError.loadMediationError("Yandex: id is empty").errorDescription,
                    "CD1" : model.placementID.description
                ]
            )

            factoryDelegate?.onAdAppOpenAdFailed(
                error: .loadMediationError("Yandex: id is empty"),
                item: .yandex(model))
            return
        }

        let configuration = AdRequestConfiguration(adUnitID: model.mediationID)

        configuration.mutableConfiguration.age = model.age as? NSNumber
        configuration.mutableConfiguration.gender = model.gender?.rawValue
        configuration.mutableConfiguration.adTheme = model.isDarkMode ? .dark : .light

        adLoader.loadAd(with: configuration)
    }

    func show(from viewController: UIViewController) {
        guard
            !isImpression
        else {
            if UserDefaults.standard.bool(forKey: "adsEnableLogging") {
                print("[Ads SDK] ERROR 🍎 Interstitial: the ad can only be shown once.")
            }

            return
        }

        appOpenAd?.show(from: viewController)
    }
}

// MARK: - AppOpenAdLoaderDelegate

extension AppOpenAdYandex: AppOpenAdLoaderDelegate {

    func appOpenAdLoader(_ adLoader: YandexMobileAds.AppOpenAdLoader, didLoad appOpenAd: YandexMobileAds.AppOpenAd) {
        isLoaded = true
        self.appOpenAd = appOpenAd
        self.appOpenAd?.delegate = self

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
                "eventValue" : "1",
                "eventContent" : "appopen",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedStringBuzzoola(),
                "filterName": model.amount.description,
                "bannerName": "[null_null]",
                "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description + "]",
                "CD1" : model.placementID.description
            ]
        )

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "ad-load-in_app",
            parameters: [
                "eventCategory" : "ad",
                "eventAction" : "load",
                "eventLabel" : "in_app",
                "eventContent" : "appopen",
                "eventContext" : "yandex",
                "bannerName" : "null_null",
                "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                "CD1" : model.placementID.description
            ]
        )

        let load = model.eventURLs.load

        for url in load {
            AdRequestSender.shared.makeEventsRequest(
                request: .init(
                    adType: .appOpenAd,
                    placementID: model.placementID,
                    creativeID: "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                    type: .load,
                    url: url,
                    adSeqNumber: model.index,
                    count: load.count))
        }

        factoryDelegate?.onAdLoaded(ad: self, item: .yandex(model))
    }
    
    func appOpenAdLoader(_ adLoader: YandexMobileAds.AppOpenAdLoader, didFailToLoadWithError error: YandexMobileAds.AdRequestError) {
        isFailed = true

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
                "eventContent" : "appopen",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedStringBuzzoola(),
                "filterName": model.amount.description,
                "bannerName": "[]",
                "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description + "]",
                "deliveryType": error.error.localizedDescription,
                "CD1" : model.placementID.description
            ]
        )

        factoryDelegate?.onAdAppOpenAdFailed(
            error: AdError.loadMediationError(error.error.localizedDescription),
            item: .yandex(model))
    }
}

// MARK: - AppOpenAdDelegate

extension AppOpenAdYandex: YandexMobileAds.AppOpenAdDelegate {

    func appOpenAdDidDismiss(_ appOpenAd: YandexMobileAds.AppOpenAd) {
        delegate?.appOpenAdDidDismiss()

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "close",
            "eventLabel" : "in_app",
            "eventContent" : "appopen",
            "eventContext" : "yandex",
            "bannerName" : "null_null",
            "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
            "CD1" : model.placementID.description
        ]

        if let data = self.impressionData {
            parameters["paymentType"] = data
        }

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "ad-close-in_app",
            parameters: parameters
        )
    }

    func appOpenAd(
        _ appOpenAd: YandexMobileAds.AppOpenAd,
        didFailToShowWithError error: Error
    ) {
        isFailed = true
        delegate?.appOpenAd(didFailToShowWithError: .loadMediationError(error.localizedDescription))
    }

    func appOpenAdDidShow(_ appOpenAd: YandexMobileAds.AppOpenAd) {      delegate?.appOpenAdDidShow()
    }

    func appOpenAdDidClick(_ appOpenAd: YandexMobileAds.AppOpenAd) {
        delegate?.appOpenAdDidClick()

        if isFirstEventClick {

            var parameters = [
                "eventCategory" : "ad",
                "eventAction" : "click",
                "eventLabel" : "in_app",
                "eventContent" : "appopen",
                "eventContext" : "yandex",
                "bannerName" : "null_null",
                "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                "CD1" : model.placementID.description
            ]

            if let data = self.impressionData {
                parameters["paymentType"] = data
            }

            BuzzoolaAdsAnalyticsManager.shared.track(
                eventName: "ad-click-in_app",
                parameters: parameters
            )

            let click = model.eventURLs.click

            for url in click {
                AdRequestSender.shared.makeEventsRequest(
                    request: .init(
                        adType: .appOpenAd,
                        placementID: model.placementID,
                        creativeID: "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                        type: .click,
                        url: url,
                        adSeqNumber: model.index,
                        count: click.count))
            }

            isFirstEventClick = false
        }
    }

    func appOpenAd(_ appOpenAd: YandexMobileAds.AppOpenAd, didTrackImpressionWith impressionData: ImpressionData?) {
        isImpression = true

        delegate?.appOpenAd(didTrackImpressionWith: impressionData?.rawData)
        self.impressionData = impressionData?.rawData

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "show",
            "eventLabel" : "in_app",
            "eventContent" : "appopen",
            "eventContext" : "yandex",
            "bannerName" : "null_null",
            "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
            "CD1" : model.placementID.description
        ]

        if let data = self.impressionData {
            parameters["paymentType"] = data
        }

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "ad-show-in_app",
            parameters: parameters
        )

        let impression = model.eventURLs.impression

        for url in impression {
            AdRequestSender.shared.makeEventsRequest(
                request: .init(
                    adType: .appOpenAd,
                    placementID: model.placementID,
                    creativeID: "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                    type: .impression,
                    url: url,
                    adSeqNumber: model.index,
                    count: impression.count))
        }
    }
}
