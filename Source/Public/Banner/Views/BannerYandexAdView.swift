//
//  BannerYandexAdView.swift
//  BuzzoolaAdsSDKYandex
//
//  Created by Коротаева Елена Сергеевна on 15.05.2024.
//

import Foundation
import YandexMobileAds
import BuzzoolaAdsSDK

protocol BannerYandexAdViewLoaderDelegate: AnyObject {
    func bannerAdViewFailed(adError: AdError)
    func bannerAdViewLoaded()
}

final class BannerYandexAdView: UIView, BannerAdViewProtocol {

    private var bannerSize = BannerAdSize.inlineSize(
        withWidth: 0,
        maxHeight: 0)

    private var adUnitID: String?

    private lazy var adView: AdView = {
        let adView = AdView(adUnitID: adUnitID ?? "", adSize: bannerSize)
        return adView
    }()

    private var eventsURLs: AdsMeditationItemModel.EventURL?

    private var model: AdsMeditationItemModel?

    public weak var delegate: BannerCurrentAdEventProtocol?

    weak var failedDelegate: BannerYandexAdViewLoaderDelegate?

    private var isFirstEventClick = true

    private var impressionData: String?

    private var isImpression = false

    private var isLoaded = false

    private var isFailed = false

    // MARK: Initializers

    public init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Deinitializers

    deinit {
        NotificationCenter.default.removeObserver(self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil)

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

        if let impressionLocalError = impressionLocalError {            BuzzoolaAdsAnalyticsManager.shared.track(
                eventName: "ad-impression_error-in_app",
                parameters: [
                    "eventCategory" : "ad",
                    "eventAction" : "impression_error",
                    "eventLabel" : "in_app",
                    "eventContent" : "banner",
                    "eventContext" : "yandex",
                    "filterName": impressionLocalError.filterName,
                    "bannerName" : impressionLocalError.bannerName,
                    "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + (model?.index.description ?? ""),
                    "CD1" : model?.placementID.description ?? ""
                ])
        }
    }
}

// MARK: - Public functions

extension BannerYandexAdView {

    func loadAds(request: AdsMeditationItemModel) {
        model = request
        let bannerWidth = CGFloat(request.width ?? 0)
        let bannerHeight = CGFloat(request.height ?? 0)

        eventsURLs = request.eventURLs
        
        bannerSize = BannerAdSize.inlineSize(
            withWidth: bannerWidth,
            maxHeight: bannerHeight)

        adUnitID = request.mediationID

        configureUI()

        let adRequest = MutableAdRequest()

        adRequest.gender = request.gender?.rawValue
        adRequest.age = request.age as? NSNumber
        adRequest.adTheme = request.isDarkMode ? .dark : .light

        adView.loadAd(with: adRequest)
    }
}

// MARK: - AdViewDelegate

extension BannerYandexAdView: AdViewDelegate {

    func adViewDidLoad(_ adView: AdView) {
        isLoaded = true

        guard
            let model = model
        else {
            return
        }

        let load = eventsURLs?.load ?? []

        for url in load {
            AdRequestSender.shared.makeEventsRequest(
                request: .init(
                    adType: .banner,
                    placementID: model.placementID,
                    creativeID: "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
                    type: .load,
                    url: url,
                    adSeqNumber: 1,
                    count: load.count))
        }

        BuzzoolaAdsAnalyticsManager.shared.track(
            eventName: "ad-load-in_app",
            parameters: [
                "eventCategory" : "ad",
                "eventAction" : "load",
                "eventLabel" : "in_app",
                "eventContent" : "banner",
                "eventContext" : "yandex",
                "bannerName" : "null_null",
                "bannerID" : "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
                "CD1" : model.placementID.description
            ]
        )

        failedDelegate?.bannerAdViewLoaded()
    }

    func adViewDidClick(_ adView: AdView) {
        delegate?.onAdClicked()

        guard
            let model = model,
            isFirstEventClick
        else {
            return
        }

        let click = eventsURLs?.click ?? []

        for url in click {
            AdRequestSender.shared.makeEventsRequest(
                request: .init(
                    adType: .banner,
                    placementID: model.placementID,
                    creativeID: "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
                    type: .click,
                    url: url,
                    adSeqNumber: 1,
                    count: click.count))
        }

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "click",
            "eventLabel" : "in_app",
            "eventContent" : "banner",
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

        isFirstEventClick = false
    }

    func adView(_ adView: AdView, didTrackImpression impressionData: ImpressionData?) {
        isImpression = true
        
        delegate?.onImpression(impressionData?.rawData)

        self.impressionData = impressionData?.rawData

        guard
            let model = model
        else {
            return
        }

        let impression = eventsURLs?.impression ?? []

        for url in impression {
            AdRequestSender.shared.makeEventsRequest(
                request: .init(
                    adType: .banner,
                    placementID: model.placementID,
                    creativeID: "yandex_" + Date().timeIntervalSince1970.roundedString() + "_" + model.index.description,
                    type: .impression,
                    url: url,
                    adSeqNumber: 1,
                    count: impression.count))
        }

        var parameters = [
            "eventCategory" : "ad",
            "eventAction" : "show",
            "eventLabel" : "in_app",
            "eventContent" : "banner",
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
    }

    func adViewDidFailLoading(_ adView: AdView, error: Error) {
        isFailed = true

        guard
            let model = model
        else {
            return
        }

        failedDelegate?.bannerAdViewFailed(adError: .loadMediationError(error.localizedDescription))
    }

    func adViewWillLeaveApplication(_ adView: AdView) {
        delegate?.onLeftApplication()

        configureNotification()
    }

    func close(_ adView: AdView) {
        adView.isHidden = true
    }
}

// MARK: - Actions

extension BannerYandexAdView {

    @objc
    func applicationDidBecomeActive() {
        delegate?.onReturnedToApplication()

        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
}

// MARK: - Configure UI

private extension BannerYandexAdView {

    func configureUI() {
        configureViews()
        configureConstraints()
        configureStyle()
    }

    func configureViews() {
        addSubview(adView)
    }

    func configureConstraints() {
        adView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            adView.leadingAnchor.constraint(equalTo: leadingAnchor),
            adView.topAnchor.constraint(equalTo: topAnchor),
            adView.trailingAnchor.constraint(equalTo: trailingAnchor),
            adView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configureStyle() {
        adView.delegate = self
        backgroundColor = .clear
    }

    func configureNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
    }
}
