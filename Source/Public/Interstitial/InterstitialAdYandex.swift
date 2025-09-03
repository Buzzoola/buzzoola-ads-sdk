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

    var factoryDelegate: InterstitialAdFactoryDelegate?

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

    // MARK: Initializer

    init(model: AdsMeditationItemModel) {
        self.model = model
    }

    // MARK: Functions

    func loadAd() {
        let configuration = AdRequestConfiguration(adUnitID: model.mediationID)

        configuration.mutableConfiguration.age = model.age as? NSNumber
        configuration.mutableConfiguration.gender = model.gender?.rawValue
        configuration.mutableConfiguration.adTheme = model.isDarkMode ? .dark : .light

        adLoader.loadAd(with: configuration)

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
    }

    func show(from viewController: UIViewController) {
        interstitialAd?.show(from: viewController)
    }
}

// MARK: - InterstitialAdLoaderDelegate

extension InterstitialAdYandex: InterstitialAdLoaderDelegate {

    func interstitialAdLoader(_ adLoader: YandexMobileAds.InterstitialAdLoader, didLoad interstitialAd: YandexMobileAds.InterstitialAd) {
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
            AdRequestSender.shared.makeEventsRequest(request: .init(type: .load, url: url, adSeqNumber: model.index))
        }

        factoryDelegate?.onAdLoaded(ad: self, item: .yandex(model))
    }
    
    func interstitialAdLoader(_ adLoader: YandexMobileAds.InterstitialAdLoader, didFailToLoadWithError error: YandexMobileAds.AdRequestError) {
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
        delegate?.onAdFailed(adError: .loadMediationError(error.localizedDescription))
    }

    func interstitialAd(_ interstitialAd: YandexMobileAds.InterstitialAd, didTrackImpressionWith impressionData: (any ImpressionData)?) {
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
            AdRequestSender.shared.makeEventsRequest(request: .init(type: .impression, url: url, adSeqNumber: model.index))
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
                AdRequestSender.shared.makeEventsRequest(request: .init(type: .click, url: url, adSeqNumber: model.index))
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
