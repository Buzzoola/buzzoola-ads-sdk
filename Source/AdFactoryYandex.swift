//
//  BuzzoolaAdsSDKYandex.swift
//  BuzzoolaAdsSDKYandex
//
//  Created by Коротаева Елена Сергеевна on 16.05.2024.
//

import BuzzoolaAdsSDK

class AdFactoryYandex: NSObject, AdFactory {

    weak var delegate: AdFactoryDelegate?

    // MARK: Private properties

    private let model: AdsMeditationItemModel

    // MARK: Initializer

    required init?(data: AdsItem) {
        if case .yandex(let model) = data {
            self.model = model
        } else {
            return nil
        }
    }

    // MARK: Functions

    func changeAmount(to amount: Int) {
        model.amount = amount
    }
    
    func createBannerAd() -> BannerAd {
        let bannerAd = BannerAdYandex(model: model)
        
        bannerAd.factoryDelegate = delegate
        return bannerAd
    }

    func createNativeAd() -> NativeAdObject {
        let nativeAd = NativeAdYandexObject(model: model)

        nativeAd.factoryDelegate = delegate
        return nativeAd
    }

    func createVideoAd() -> VideoAd? {
        return nil
    }

    func createInterstitialAd() -> BuzzoolaAdsSDK.InterstitialAd {
        let interstitialAd = InterstitialAdYandex(model: model)

        interstitialAd.factoryDelegate = delegate
        return interstitialAd
    }

    func createRewardedAd() -> BuzzoolaAdsSDK.RewardedAd {
        let rewardedAd = RewardedAdYandex(model: model)

        rewardedAd.factoryDelegate = delegate
        return rewardedAd
    }

    func configure(completion: @escaping () -> ()) {
        AdsYandex.configure {
            completion()
        }
    }
}
