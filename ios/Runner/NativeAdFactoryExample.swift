import GoogleMobileAds
import google_mobile_ads

class NativeAdFactoryExample: NSObject, FLTNativeAdFactory {

    func createNativeAd(_ nativeAd: GADNativeAd, customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {

        // Load the XIB and cast to GADNativeAdView
        guard let adView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first as? GADNativeAdView else {
            print("❌ Failed to load NativeAdView.xib")
            return nil
        }

        // Populate the ad view
        if let headlineLabel = adView.headlineView as? UILabel {
            headlineLabel.text = nativeAd.headline
        }

        if let bodyLabel = adView.bodyView as? UILabel {
            bodyLabel.text = nativeAd.body
            adView.bodyView?.isHidden = nativeAd.body == nil
        }

        if let ctaButton = adView.callToActionView as? UIButton {
            ctaButton.setTitle(nativeAd.callToAction, for: .normal)
            adView.callToActionView?.isHidden = nativeAd.callToAction == nil
            adView.callToActionView?.isUserInteractionEnabled = false // Required
        }

        if let iconImageView = adView.iconView as? UIImageView {
            iconImageView.image = nativeAd.icon?.image
            adView.iconView?.isHidden = nativeAd.icon == nil
        }

        if let storeLabel = adView.storeView as? UILabel {
            storeLabel.text = nativeAd.store
            adView.storeView?.isHidden = nativeAd.store == nil
        }

        if let priceLabel = adView.priceView as? UILabel {
            priceLabel.text = nativeAd.price
            adView.priceView?.isHidden = nativeAd.price == nil
        }

        if let advertiserLabel = adView.advertiserView as? UILabel {
            advertiserLabel.text = nativeAd.advertiser
            adView.advertiserView?.isHidden = nativeAd.advertiser == nil
        }

        if let media = adView.mediaView as? GADMediaView {
            media.mediaContent = nativeAd.mediaContent
        }

        // Associate native ad object with the view
        adView.nativeAd = nativeAd

        return adView
    }
}
