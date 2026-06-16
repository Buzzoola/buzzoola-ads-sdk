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

    private lazy var adLoader = NativeBulkAdLoader()

    private var startDate: Date?

    // MARK: Initializer

    init(model: AdsMeditationItemModel) {
        self.model = model
    }

    // MARK: Functions

    func loadAd() {
        self.startDate = Date()

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "request-send-from_sdk_to_adapter",
            parameters: [
                "eventCategory" : "request",
                "eventAction" : "send",
                "eventLabel" : "from_sdk_to_adapter",
                "eventValue" : self.model.amount.description,
                "eventContent" : "native",
                "eventContext" : "yandex",
                "CD1" : self.model.placementID.description
            ]
        )

        guard
            self.model.mediationID != ""
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
                    "buttonLocation" : (Date().timeIntervalSince(startDate!) * 1000).roundedStringBuzzoola(),
                    "filterName": self.model.amount.description,
                    "bannerName": "[]",
                    "bannerID": "[]",
                    "deliveryType": AdError.loadMediationError("Yandex: id is empty").errorDescription,
                    "CD1" : self.model.placementID.description
                ]
            )

            self.factoryDelegate?.onAdNativeFailed(
                error: .loadMediationError("Yandex: id is empty"),
                item: .yandex(model))
            return
        }
        
        let targeting = AdTargeting(
            age: self.model.age as? NSNumber,
            gender: self.model.gender == .male ? .male : .female
        )

        let configuration = AdRequest(
            adUnitID: self.model.mediationID,
            targeting: targeting,
            adTheme: self.model.isDarkMode ? .dark : .light)

        self.adLoader.loadAds(with: configuration, adsCount: UInt(self.model.amount)) { [weak self] in
            guard
                let self
            else {
                return
            }

            switch $0 {
            case .success(let ads):
                ads.enumerated().forEach { number, ad in
                    let bulkModel = AdsMeditationItemModel(
                        index: number + 1,
                        placementID: self.model.placementID,
                        mediationID: self.model.mediationID,
                        width: self.model.width,
                        height: self.model.height,
                        eventURLs: self.model.eventURLs,
                        gender: self.model.gender,
                        age: self.model.age,
                        amount: self.model.amount,
                        isDarkMode: self.model.isDarkMode)

                    let adItem = NativeAdYandex(model: bulkModel, ad: ad)
                    self.ads.append(adItem)
                }

                factoryDelegate?.onAdLoaded(ad: self, item: .yandex(model))
            case .failure(let error):
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
                        "buttonLocation" : (Date().timeIntervalSince(startDate) * 1000).roundedStringBuzzoola(),
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
    }
}
