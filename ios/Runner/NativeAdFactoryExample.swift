// import GoogleMobileAds
// import google_mobile_ads

/**
 * The example NativeAdView.xib can be found at
 * github.com/googleads/googleads-mobile-flutter/blob/main/packages/google_mobile_ads/
 *     example/ios/Runner/NativeAdView.xib
 */
/*
class NativeAdFactoryExample: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: GADNativeAd, customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        // Create and place the ad in the view hierarchy.
        let adView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first as! GADNativeAdView

        // Populate the native ad view with the native ad assets.
        // The headline is guaranteed to be present in every native ad.
        if let headline = nativeAd.headline, !headline.isEmpty {
            (adView.headlineView as? UILabel)?.text = headline
        } else {
            (adView.headlineView as? UILabel)?.text = "Check out this amazing offer!"
        }


        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        if let body = nativeAd.body, !body.isEmpty {
            (adView.bodyView as? UILabel)?.text = body
            adView.bodyView?.isHidden = false
        } else {
            (adView.bodyView as? UILabel)?.text = "Discover amazing products tailored for you."
            adView.bodyView?.isHidden = false
        }

        (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        adView.callToActionView?.isHidden = nativeAd.callToAction == nil

        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image


        (adView.storeView as? UILabel)?.text = nativeAd.store
        adView.storeView?.isHidden = nativeAd.store == nil

        (adView.priceView as? UILabel)?.text = nativeAd.price
        adView.priceView?.isHidden = nativeAd.price == nil

        (adView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        adView.advertiserView?.isHidden = nativeAd.advertiser == nil

        // In order for the SDK to process touch events properly, user interaction
        // should be disabled.
        adView.callToActionView?.isUserInteractionEnabled = false

        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        adView.nativeAd = nativeAd

        return adView
    }
}
*/