//
//  AdsYandex.swift
//  BuzzoolaAdsSDKYandex
//
//  Created by Коротаева Елена Сергеевна on 13.05.2024.
//

import Foundation
import YandexMobileAds

public final class AdsYandex {

    private static var initialized = false

    public init() {}

    public static func configure(completion: @escaping () -> ()) {
        if AdsYandex.initialized {
            completion()
        } else {
            MobileAds.initializeSDK { }

            completion()

            AdsYandex.initialized = true
        }
    }
}
