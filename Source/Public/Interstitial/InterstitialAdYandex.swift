//
//  InterstitialAdYandex.swift
//  BuzzoolaAdsSDKYandex
//
//  Created by Коротаева Елена Сергеевна on 19.08.2024.
//

import Foundation
import YandexMobileAds
import BuzzoolaAdsSDK

final class InterstitialAdYandex: BaseInterstitialAd, BuzzoolaAdsSDK.InterstitialAd {

    // MARK: Properties

    weak var factoryDelegate: InterstitialAdFactoryDelegate?

    // MARK: Private properties

    private let model: AdsMeditationItemModel

    private lazy var adLoader: YandexMobileAds.InterstitialAdLoader = {
        let adLoader = YandexMobileAds.InterstitialAdLoader()
        adLoader.delegate = self
        return adLoader
    }()

    private var interstitialAd: YandexMobileAds.InterstitialAd?

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
                    "eventContent" : "interstitial",
                    "eventContext" : "yandex",
                    "filterName": impressionLocalError.filterName,
                    "bannerName" : impressionLocalError.bannerName,
                    "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
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
                print("[Ads SDK] ERROR 🍎 Interstitial Yandex: id is empty")
            }

            BuzzoolaAdsAnalyticsManager.shared.track(
                eventName: "response-get-from_adapter_to_sdk",
                parameters: [
                    "eventCategory" : "response",
                    "eventAction" : "get",
                    "eventLabel" : "from_adapter_to_sdk",
                    "eventValue" : "0",
                    "eventContent" : "interstitial",
                    "eventContext" : "yandex",
                    "buttonLocation" : (Date().timeIntervalSince(startDate!) * 1000).roundedString(),
                    "filterName": model.amount.description,
                    "bannerName": "[]",
                    "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description + "]",
                    "deliveryType": AdError.loadMediationError("Yandex: id is empty").errorDescription,
                    "CD1" : model.placementID.description
                ]
            )

            factoryDelegate?.onAdInterstitialFailed(
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

        interstitialAd?.show(from: viewController)
    }
}

// MARK: - InterstitialAdLoaderDelegate

extension InterstitialAdYandex: InterstitialAdLoaderDelegate {

    func interstitialAdLoader(_ adLoader: YandexMobileAds.InterstitialAdLoader, didLoad interstitialAd: YandexMobileAds.InterstitialAd) {
        isLoaded = true
        self.interstitialAd = interstitialAd
        self.interstitialAd?.delegate = self

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
                "eventContent" : "interstitial",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedString(),
                "filterName": model.amount.description,
                "bannerName": "[null_null]",
                "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description + "]",
                "CD1" : model.placementID.description
            ]
        )

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "ad-load-in_app",
            parameters: [
                "eventCategory" : "ad",
                "eventAction" : "load",
                "eventLabel" : "in_app",
                "eventContent" : "interstitial",
                "eventContext" : "yandex",
                "bannerName" : "null_null",
                "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
                "CD1" : model.placementID.description
            ]
        )

        let load = model.eventURLs.load

        for url in load {
            AdRequestSender.shared.makeEventsRequest(
                request: .init(
                    adType: .interstitial,
                    placementID: model.placementID,
                    creativeID: "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
                    type: .load,
                    url: url,
                    adSeqNumber: model.index,
                    count: load.count))
        }

        factoryDelegate?.onAdLoaded(ad: self, item: .yandex(model))
    }
    
    func interstitialAdLoader(_ adLoader: YandexMobileAds.InterstitialAdLoader, didFailToLoadWithError error: YandexMobileAds.AdRequestError) {
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
                "eventContent" : "interstitial",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedString(),
                "filterName": model.amount.description,
                "bannerName": "[]",
                "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description + "]",
                "deliveryType": error.error.localizedDescription,
                "CD1" : model.placementID.description
            ]
        )

        factoryDelegate?.onAdInterstitialFailed(
            error: AdError.loadMediationError(error.error.localizedDescription),
            item: .yandex(model))
    }
}

// MARK: - InterstitialAdDelegate

extension InterstitialAdYandex: YandexMobileAds.InterstitialAdDelegate {

    func interstitialAd(_ interstitialAd: YandexMobileAds.InterstitialAd, didFailToShowWithError error: any Error) {
        isFailed = true
        delegate?.onAdFailed(adError: .loadMediationError(error.localizedDescription))
    }

    func interstitialAd(_ interstitialAd: YandexMobileAds.InterstitialAd, didTrackImpressionWith impressionData: (any ImpressionData)?) {
        isImpression = true

        delegate?.onImpression(impressionData?.rawData)
        self.impressionData = impressionData?.rawData

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "show",
            "eventLabel" : "in_app",
            "eventContent" : "interstitial",
            "eventContext" : "yandex",
            "bannerName" : "null_null",
            "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
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
                    adType: .interstitial,
                    placementID: model.placementID,
                    creativeID: "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
                    type: .impression,
                    url: url,
                    adSeqNumber: model.index,
                    count: impression.count))
        }
    }

    func interstitialAdDidShow(_ interstitialAd: YandexMobileAds.InterstitialAd) {
        delegate?.onAdShown()
    }

    func interstitialAdDidClick(_ interstitialAd: YandexMobileAds.InterstitialAd) {
        delegate?.onAdClicked()

        if isFirstEventClick {

            var parameters = [
                "eventCategory" : "ad",
                "eventAction" : "click",
                "eventLabel" : "in_app",
                "eventContent" : "interstitial",
                "eventContext" : "yandex",
                "bannerName" : "null_null",
                "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
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
                        adType: .interstitial,
                        placementID: model.placementID,
                        creativeID: "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
                        type: .click,
                        url: url,
                        adSeqNumber: model.index,
                        count: click.count))
            }

            isFirstEventClick = false
        }
    }

    func interstitialAdDidDismiss(_ interstitialAd: YandexMobileAds.InterstitialAd) {
        delegate?.onAdDismissed()

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "close",
            "eventLabel" : "in_app",
            "eventContent" : "interstitial",
            "eventContext" : "yandex",
            "bannerName" : "null_null",
            "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
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
}
