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
        switch ad.adType {
        case .appInstall:
            return .app
        case .content, .media:
            return .content
        @unknown default:
            return .content
        }
    }()

    // MARK: Private properties

    private var model: AdsMeditationItemModel

    private let ad: YandexMobileAds.NativeAd

    private var adView: NativeAdYandexView?

    private var isFirstEventClick = true

    private var impressionData: String?

    // MARK: Initializer

    init(model: AdsMeditationItemModel, ad: YandexMobileAds.NativeAd) {
        self.model = model
        self.ad = ad
    }

    // MARK: Functions

    func bindAd(_ view: NativeAdView) {
        adView = NativeAdYandexView(nativeAdView: view)

        ad.loadImages()
        ad.add(self)

        configureAssets(ad: ad)
        delegate?.onAdLoaded(self)

        let load = model.eventURLs.load

        for url in load {
            AdRequestSender.shared.makeEventsRequest(request: .init(type: .load, url: url, adSeqNumber: model.index))
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
                "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
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

    func destroy() {
        adView?.removeFromSuperview()
        adView = nil

        ad.remove(self)

        NotificationCenter.default.removeObserver(self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
}

// MARK: - Actions

extension NativeAdYandex {

    @objc
    func applicationDidBecomeActive() {
        delegate?.onReturnedToApplication(self)

        NotificationCenter.default.removeObserver(self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
}

//MARK: - Private functions

private extension NativeAdYandex {

    func configureNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }

    func configureAssets(ad: YandexMobileAds.NativeAd) {
        adAssets.age = ad.adAssets().age
        adAssets.actionTitle = ad.adAssets().callToAction
        adAssets.description = ad.adAssets().description
        adAssets.domain = ad.adAssets().domain
        adAssets.title = ad.adAssets().title
        adAssets.rating = ad.adAssets().rating
        adAssets.reviewCount = ad.adAssets().reviewCount
        adAssets.warning = ad.adAssets().warning
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
                AdRequestSender.shared.makeEventsRequest(request: .init(type: .click, url: url, adSeqNumber: model.index))
            }

            var parameters = [
                "eventCategory" : "ad",
                "eventAction" : "click",
                "eventLabel" : "in_app",
                "eventContent" : "native",
                "eventContext" : "yandex",
                "bannerName" : (ad.adAssets().domain ?? "null") + "_" + (ad.adAssets().title ?? "null"),
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

            isFirstEventClick = false
        }
    }

    func nativeAdWillLeaveApplication(_ ad: YandexMobileAds.NativeAd) {
        delegate?.onLeftApplication(self)

        configureNotification()
    }

    func nativeAd(_ ad: YandexMobileAds.NativeAd, didTrackImpressionWith impressionData: ImpressionData?) {
        delegate?.onImpression(self, impressionData?.rawData)
        self.impressionData = impressionData?.rawData

        let impression = model.eventURLs.impression

        for url in impression {
            AdRequestSender.shared.makeEventsRequest(request: .init(type: .impression, url: url, adSeqNumber: model.index))
        }

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "show",
            "eventLabel" : "in_app",
            "eventContent" : "native",
            "eventContext" : "yandex",
            "bannerName" : (ad.adAssets().domain ?? "null") + "_" + (ad.adAssets().title ?? "null"),
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
    }

    func close(_ ad: YandexMobileAds.NativeAd) {
        delegate?.onCloseAd(self)

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "close",
            "eventLabel" : "in_app",
            "eventContent" : "native",
            "eventContext" : "yandex",
            "bannerName" : (ad.adAssets().domain ?? "null") + "_" + (ad.adAssets().title ?? "null"),
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

// MARK: - NativeAdImageLoadingObserver

extension NativeAdYandex: NativeAdImageLoadingObserver {

    func nativeAdDidFinishLoadingImages(_ ad: any YandexMobileAds.NativeAd) {
        let media = ad.adAssets().image

        adAssets.image = media?.imageValue
        adAssets.icon = ad.adAssets().icon?.imageValue
        adAssets.favicon = ad.adAssets().favicon?.imageValue

        let color = media?.imageValue?.getColors()

        imageDelegate?.onImageLoaded(color: color?.background)
    }
}
