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

    // MARK: Initializer

    init(model: AdsMeditationItemModel) {
        self.model = model
    }

    // MARK: Functions

    func show() {
        guard
            model.mediationID != ""
        else {
            if UserDefaults.standard.bool(forKey: "adsEnableLogging") {
                print("[Ads SDK] ERROR 🍎 Banner Yandex: id is empty")
            }
            
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
            let bannerView = bannerView
        else {
            return
        }

        factoryDelegate?.bannerViewLoaded(item: .yandex(model), view: bannerView)
    }

    func bannerAdViewFailed(adError: BuzzoolaAdsSDK.AdError) {
        factoryDelegate?.bannerFailed(adError: adError, item: .yandex(model))
    }
}
