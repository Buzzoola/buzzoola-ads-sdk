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

    private var nativeAdViewSuperview: UIView?

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

    func destroy() {
        nativeAdView.removeFromSuperview()
        nativeAdView.adMedia?.content?.removeFromSuperview()
        nativeAdView.adMedia?.backgroundColor = .clear
        nativeAdView.adInfo?.removeTarget(nil, action: nil, for: .allEvents)
        nativeAdView.adActionBtn?.removeTarget(nil, action: nil, for: .allEvents)
        nativeAdView.gestureRecognizers?.removeAll()
        nativeAdView.adTitle?.gestureRecognizers?.removeAll()
        nativeAdView.adDescription?.gestureRecognizers?.removeAll()
        nativeAdView.adMedia?.gestureRecognizers?.removeAll()
        gestureRecognizers?.removeAll()

        nativeAdView.adTitle?.text = ""
        nativeAdView.adDomain?.text = ""
        nativeAdView.adBadge?.text = ""
        nativeAdView.adAge?.text = ""
        nativeAdView.adPrice?.text = ""
        nativeAdView.adDescription?.text = ""
        nativeAdView.adWarning?.text = ""
        nativeAdView.adReviews?.text = ""
        nativeAdView.adFavicon?.image = nil
        nativeAdView.adIcon?.image = nil
        nativeAdView.adRating?.setRating(0)
        nativeAdView.adActionBtn?.setTitle("", for: .normal)

        guard
            let nativeAdViewSuperview
        else {
            return
        }

        nativeAdViewSuperview.addSubview(nativeAdView)

        NSLayoutConstraint.activate([
            nativeAdViewSuperview.topAnchor.constraint(equalTo: nativeAdView.topAnchor),
            nativeAdViewSuperview.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor),
            nativeAdViewSuperview.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor),
            nativeAdViewSuperview.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor)
        ])

        removeFromSuperview()
    }
}

// MARK: - Private functions

private extension NativeAdYandexView {

    func configure() {
        nativeAdViewSuperview = nativeAdView.superview

        nativeAdViewSuperview?.addSubview(self)
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
