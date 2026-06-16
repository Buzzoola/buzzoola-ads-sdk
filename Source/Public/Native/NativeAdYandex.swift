//
//  NativeAdYandex.swift
//  BuzzoolaAdsSDKYandex
//
//  Created by Коротаева Елена Сергеевна on 03.06.2024.
//

import Foundation
import YandexMobileAds
import UIKit
import BuzzoolaAdsSDK

final class NativeAdYandex: BaseNativeAd, BuzzoolaAdsSDK.NativeAd {

    // MARK: Properties

    var adAssets = BuzzoolaAdsSDK.NativeAdAssets()

    var meta: [String : Any?]?

    lazy var type: BuzzoolaAdsSDK.NativeAdType = {
        MainActor.assumeIsolated {
            switch ad.adType {
            case .appInstall:
                return .app
            case .content, .media:
                return .content
            @unknown default:
                return .content
            }
        }
    }()

    // MARK: Private properties

    private var model: AdsMeditationItemModel

    private let ad: YandexMobileAds.NativeAd

    private var adView: NativeAdYandexView?

    private var isFirstEventClick = true

    private var impressionData: String?

    private var isImpression = false

    private var isLoaded = false

    // MARK: Initializer

    init(model: AdsMeditationItemModel, ad: YandexMobileAds.NativeAd) {
        self.model = model
        self.ad = ad
    }

    deinit {
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
                    "eventContent" : "native",
                    "eventContext" : "yandex",
                    "filterName": impressionLocalError.filterName,
                    "bannerName" : impressionLocalError.bannerName,
                    "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                    "CD1" : model.placementID.description
                ])
        }
    }

    // MARK: Functions

    @MainActor func bindAd(_ view: BuzzoolaAdsSDK.NativeAdView) {
        Task { @MainActor in
            adView = NativeAdYandexView(nativeAdView: view)
            self.ad.loadImages {
                let media = self.ad.adAssets().image
                
                self.adAssets.image = media?.imageValue
                self.adAssets.icon = self.ad.adAssets().icon?.imageValue
                self.adAssets.favicon = self.ad.adAssets().favicon?.imageValue
                
                let color = media?.imageValue?.getColors()
                
                self.adView?.nativeAdView.adMedia?.backgroundColor = color?.background
                
                self.imageDelegate?.onImageLoaded(ad: self, color: color?.background)
            }
            
            isLoaded = true
            
            await configureAssets(ad: ad)
            delegate?.onAdLoaded(self)
            
            let load = model.eventURLs.load
            
            for url in load {
                AdRequestSender.shared.makeEventsRequest(
                    request: .init(
                        adType: .native,
                        placementID: model.placementID,
                        creativeID: "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                        type: .load,
                        url: url,
                        adSeqNumber: model.index,
                        count: load.count))
            }
            
            BuzzoolaAdsAnalyticsManager.shared.track(
                eventName: "ad-load-in_app",
                parameters: [
                    "eventCategory" : "ad",
                    "eventAction" : "load",
                    "eventLabel" : "in_app",
                    "eventContent" : "native",
                    "eventContext" : "yandex",
                    "bannerName" : (ad.adAssets().domain ?? "null") + "_" + (ad.adAssets().title ?? "null"),
                    "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                    "CD1" : model.placementID.description
                ]
            )
            
            ad.delegate = self
            
            do {
                try ad.bind(with: adView!)
            } catch {
                if UserDefaults.standard.bool(forKey: "adsEnableLogging") {
                    print("[Ads SDK] ERROR 🍎 Native Yandex: binding error: \(error)")
                }
            }
        }
    }

    func destroy() {
        Task { @MainActor in
            adView?.destroy()
            adView = nil
            
            ad.delegate = nil
        }

        NotificationCenter.default.removeObserver(self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
}

//MARK: - Private functions

private extension NativeAdYandex {

    @MainActor func configureAssets(ad: YandexMobileAds.NativeAd) {
        adAssets.age = ad.adAssets().age
        adAssets.actionTitle = ad.adAssets().callToAction
        adAssets.description = ad.adAssets().description
        adAssets.domain = ad.adAssets().domain
        adAssets.title = ad.adAssets().title
        adAssets.rating = ad.adAssets().rating
        adAssets.reviewCount = ad.adAssets().reviewCount
        adAssets.warning = ad.adAssets().warning?.value
        adAssets.sponsored = ad.adAssets().sponsored
        adAssets.price = ad.adAssets().price
        adAssets.image = ad.adAssets().image?.imageValue
        adAssets.icon = ad.adAssets().icon?.imageValue
    }
}

// MARK: - YMANativeAdDelegate

extension NativeAdYandex: YandexMobileAds.NativeAdDelegate {

    func nativeAdDidClick(_ ad: YandexMobileAds.NativeAd) {
        delegate?.onAdClicked(self)

        if isFirstEventClick {
            let click = model.eventURLs.click

            for url in click {
                AdRequestSender.shared.makeEventsRequest(
                    request: .init(
                        adType: .native,
                        placementID: model.placementID,
                        creativeID: "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                        type: .click,
                        url: url,
                        adSeqNumber: model.index,
                        count: click.count))
            }

            var parameters = [
                "eventCategory" : "ad",
                "eventAction" : "click",
                "eventLabel" : "in_app",
                "eventContent" : "native",
                "eventContext" : "yandex",
                "bannerName" : (ad.adAssets().domain ?? "null") + "_" + (ad.adAssets().title ?? "null"),
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

            isFirstEventClick = false
        }
    }

    func nativeAd(_ ad: YandexMobileAds.NativeAd, didTrackImpression impressionData: ImpressionData?) {
        isImpression = true

        delegate?.onImpression(self, impressionData?.rawData)
        self.impressionData = impressionData?.rawData

        let impression = model.eventURLs.impression

        for url in impression {
            AdRequestSender.shared.makeEventsRequest(
                request: .init(
                    adType: .native,
                    placementID: model.placementID,
                    creativeID: "yandex_" + Date().timeIntervalSince1970.roundedStringBuzzoola() + "_" + model.index.description,
                    type: .impression,
                    url: url,
                    adSeqNumber: model.index,
                    count: impression.count))
        }

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "show",
            "eventLabel" : "in_app",
            "eventContent" : "native",
            "eventContext" : "yandex",
            "bannerName" : (ad.adAssets().domain ?? "null") + "_" + (ad.adAssets().title ?? "null"),
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
    }
}
