//
//  NativeAdYandexView.swift
//  BuzzoolaAdsSDK
//
//  Created by Коротаева Елена Сергеевна on 05.06.2024.
//

import Foundation
import YandexMobileAds
import BuzzoolaAdsSDK

class NativeAdYandexView: YMANativeAdView {

    // MARK: Properties

    var nativeAdView: NativeAdView

    // MARK: Initialization

    init(nativeAdView: NativeAdView) {
        self.nativeAdView = nativeAdView

        super.init(frame: CGRect())

        configure()
        bindAssets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private functions

private extension NativeAdYandexView {

    func configure() {
        nativeAdView.superview?.addSubview(self)
        addSubview(nativeAdView)

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor)
        ])
    }

    func bindAssets() {
        let media = NativeYandexMediaView()

        nativeAdView.adMedia?.content = media
        nativeAdView.adMedia?.configureUI()

        titleLabel = nativeAdView.adTitle
        domainLabel = nativeAdView.adDomain
        warningLabel = nativeAdView.adWarning
        sponsoredLabel = nativeAdView.adBadge
        feedbackButton = nativeAdView.adInfo
        callToActionButton = nativeAdView.adActionBtn
        mediaView = media
        priceLabel = nativeAdView.adPrice
        reviewCountLabel = nativeAdView.adReviews
        ratingView = nativeAdView.adRating
        bodyLabel = nativeAdView.adDescription
        iconImageView = nativeAdView.adIcon
        faviconImageView = nativeAdView.adFavicon
        ageLabel = nativeAdView.adAge
    }
}

// MARK: - Rating

extension NativeRatingView: Rating {

    public func setRating(_ rating: NSNumber?) {
        delegate?.setRating(rating)
    }

    public func rating() -> NSNumber? {
        return delegate?.getRating()
    }
}
