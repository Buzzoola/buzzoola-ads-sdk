//
//  RewardedAdYandex.swift
//  BuzzoolaAdsSDKYandex
//
//  Created by Коротаева Елена Сергеевна on 18.10.2024.
//

import Foundation
import YandexMobileAds
import BuzzoolaAdsSDK

final class RewardedAdYandex: BaseRewardedAd, BuzzoolaAdsSDK.RewardedAd {

    // MARK: Properties

    var factoryDelegate: RewardedAdFactoryDelegate?

    // MARK: Private properties

    private let model: AdsMeditationItemModel

    private lazy var adLoader: YandexMobileAds.RewardedAdLoader = {
        let adLoader = YandexMobileAds.RewardedAdLoader()
        adLoader.delegate = self
        return adLoader
    }()

    private var rewardedAd: YandexMobileAds.RewardedAd?

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
                "eventContent" : "rewarded",
                "eventContext" : "yandex",
                "CD1" : model.placementID.description
            ]
        )
    }

    func show(from viewController: UIViewController) {
        rewardedAd?.show(from: viewController)
    }
}

// MARK: - RewardedAdLoaderDelegate

extension RewardedAdYandex: YandexMobileAds.RewardedAdLoaderDelegate {

    func rewardedAdLoader(_ adLoader: YandexMobileAds.RewardedAdLoader, didLoad rewardedAd: YandexMobileAds.RewardedAd) {
        self.rewardedAd = rewardedAd
        self.rewardedAd?.delegate = self

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
                "eventContent" : "rewarded",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedString(),
                "filterName": model.amount.description,
                "bannerName": "[null_null]",
                "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description + "]",
                "CD1" : model.placementID.description
            ]
        )

        factoryDelegate?.onAdLoaded(ad: self, item: .yandex(model))
    }

    func rewardedAdLoader(_ adLoader: YandexMobileAds.RewardedAdLoader, didFailToLoadWithError error: YandexMobileAds.AdRequestError) {
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
                "eventContent" : "rewarded",
                "eventContext" : "yandex",
                "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedString(),
                "filterName": model.amount.description,
                "bannerName": "[]",
                "bannerID": "[" + "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description + "]",
                "deliveryType": error.error.localizedDescription,
                "CD1" : model.placementID.description
            ]
        )

        factoryDelegate?.onAdRewardedFailed(
            error: AdError.loadMediationError(error.error.localizedDescription),
            item: .yandex(model))
    }
}

// MARK: - RewardedAdDelegate

extension RewardedAdYandex: YandexMobileAds.RewardedAdDelegate {

    func rewardedAd(_ rewardedAd: YandexMobileAds.RewardedAd, didReward reward: any YandexMobileAds.Reward) {
        delegate?.onReward(reward: .init(type: reward.type, amount: reward.amount))

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "ad-uspeshnoe_poluchenie_voznagrazhdeniya-in_app",
            parameters: [
                "eventCategory" : "ad",
                "eventAction" : "uspeshnoe_poluchenie_voznagrazhdeniya",
                "eventLabel" : "in_app",
                "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
                "CD1" : model.placementID.description
            ]
        )
    }

    func rewardedAd(_ rewardedAd: YandexMobileAds.RewardedAd, didFailToShowWithError error: Error) {
        delegate?.onAdFailed(adError: .loadMediationError(error.localizedDescription))
    }

    func rewardedAdDidShow(_ rewardedAd: YandexMobileAds.RewardedAd) {
        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "ad-load-in_app",
            parameters: [
                "eventCategory" : "ad",
                "eventAction" : "load",
                "eventLabel" : "in_app",
                "eventContent" : "rewarded",
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
        
        delegate?.onAdShown()
    }

    func rewardedAdDidDismiss(_ rewardedAd: YandexMobileAds.RewardedAd) {
        delegate?.onAdDismissed()

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "close",
            "eventLabel" : "in_app",
            "eventContent" : "rewarded",
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

    func rewardedAdDidClick(_ rewardedAd: YandexMobileAds.RewardedAd) {
        delegate?.onAdClicked()

        if isFirstEventClick {
            var parameters = [
                "eventCategory" : "ad",
                "eventAction" : "click",
                "eventLabel" : "in_app",
                "eventContent" : "rewarded",
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

    func rewardedAd(_ rewardedAd: YandexMobileAds.RewardedAd, didTrackImpressionWith impressionData: ImpressionData?) {
        delegate?.onImpression(impressionData?.rawData)
        self.impressionData = impressionData?.rawData

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "show",
            "eventLabel" : "in_app",
            "eventContent" : "rewarded",
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
}
