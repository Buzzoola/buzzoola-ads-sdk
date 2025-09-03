//
//  NativeYandexMediaView.swift
//  BuzzoolaAdsSDKYandex
//
//  Created by Коротаева Елена Сергеевна on 07.06.2024.
//

import Foundation
import YandexMobileAds

class NativeYandexMediaView: YMANativeMediaView {

    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
