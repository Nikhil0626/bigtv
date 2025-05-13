package com.chotanews

import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.chotanews.R
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory


class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(GoogleMobileAdsPlugin())
        super.configureFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "adFactoryExample",
            NativeAdFactoryExample(layoutInflater))
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "adFactoryExample")
    }
}

class NativeAdFactoryExample: NativeAdFactory {
    private var layoutInflater: LayoutInflater

    constructor(layoutInflater: LayoutInflater) {
        this.layoutInflater = layoutInflater
    }

    override fun createNativeAd(nativeAd: NativeAd?, customOptions: MutableMap<String, Any>?): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.my_native_ad, null) as NativeAdView

        // Set the media view.
        adView.mediaView = adView.findViewById(R.id.ad_media)

        // Set other ad assets.
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        adView.bodyView = adView.findViewById(R.id.ad_body)
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
//        adView.iconView = adView.findViewById(R.id.ad_app_icon)
//        adView.priceView = adView.findViewById(R.id.ad_price)
//        adView.starRatingView = adView.findViewById(R.id.ad_stars)
//        adView.storeView = adView.findViewById(R.id.ad_store)
//        adView.advertiserView = adView.findViewById(R.id.ad_advertiser)

        // The headline and mediaContent are guaranteed to be in every NativeAd.
        (adView.headlineView as TextView).text = nativeAd?.headline
        adView.mediaView?.mediaContent = nativeAd?.mediaContent

        // These assets aren't guaranteed to be in every NativeAd, so it's important to
        // check before trying to display them.
        if (nativeAd?.body == null) {
            adView.bodyView?.visibility = View.INVISIBLE
        } else {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        }

        if (nativeAd?.callToAction == null) {
            adView.callToActionView?.visibility = View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

//        if (nativeAd?.icon == null) {
//            adView.iconView?.visibility = View.GONE
//        } else {
//            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
//            adView.iconView?.visibility = View.VISIBLE
//        }

//        if (nativeAd?.price == null) {
//            adView.priceView?.visibility = View.INVISIBLE
//        } else {
//            adView.priceView?.visibility = View.VISIBLE
//            (adView.priceView as TextView).text = nativeAd.price
//        }

//        if (nativeAd?.store == null) {
//            adView.storeView?.visibility = View.INVISIBLE
//        } else {
//            adView.storeView?.visibility = View.VISIBLE
//            (adView.storeView as TextView).text = nativeAd.store
//        }
//
//        if (nativeAd?.starRating == null) {
//            adView.starRatingView?.visibility = View.INVISIBLE
//        } else {
//            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
//            adView.starRatingView?.visibility = View.VISIBLE
//        }

//        if (nativeAd?.advertiser == null) {
//            adView.advertiserView?.visibility = View.INVISIBLE
//        } else {
//            adView.advertiserView?.visibility = View.VISIBLE
//            (adView.advertiserView as TextView).text = nativeAd.advertiser
//        }

        // This method tells the Google Mobile Ads SDK that you have finished populating your
        // native ad view with this native ad.
        if (nativeAd != null) {
            adView.setNativeAd(nativeAd)
        }

        return adView
    }
}

//package com.chotanews
//
//import android.content.Context
//import android.content.Intent
//import android.net.Uri
//import android.view.LayoutInflater
//import android.widget.Button
//import android.widget.TextView
//import com.google.android.gms.ads.nativead.NativeAd
//import com.google.android.gms.ads.nativead.NativeAdView
//import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
//import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory
//import android.widget.ImageView
//import com.google.android.gms.ads.nativead.MediaView
//
////import com.google.android.gms.ads.nativead.MediaView
//
//class CustomNativeAdFactory(private val context: Context) : NativeAdFactory {
//    override fun createNativeAd(
//        nativeAd: NativeAd,
//        customOptions: MutableMap<String, Any>?
//    ): NativeAdView {
//        val adView: NativeAdView = LayoutInflater.from(context)
//            .inflate(R.xml.native_ad_layout, null) as NativeAdView
//
//        // Set the headline
//        val headlineView: TextView = adView.findViewById(R.id.ad_headline)
//        headlineView.text = nativeAd.headline
//        adView.headlineView = headlineView
//
//        // Set the body
//        val bodyView: TextView = adView.findViewById(R.id.ad_body)
//        bodyView.text = nativeAd.body
//        adView.bodyView = bodyView
//
//        // Set CTA button
//        val ctaButton: Button = adView.findViewById(R.id.ad_cta)
//        ctaButton.text = "https://play.google.com/store/apps/details?id=com.chotanews"
//
//
//        ctaButton.setOnClickListener {  }
//
//        // Set image view (or mediaView if available)
//        val imageView: ImageView = adView.findViewById(R.id.ad_image)
//        if (nativeAd.images.isNotEmpty() && nativeAd.images[0] != null) {
//            imageView.setImageDrawable(nativeAd.images[0].drawable)
//        }
//        adView.imageView = imageView
//
//        // Register the native ad with the view
//        adView.setNativeAd(nativeAd)
//
//        return adView
//    }
//}
//
//class MainActivity : FlutterActivity() {
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        GoogleMobileAdsPlugin.registerNativeAdFactory(
//            flutterEngine,
//            "custom_native_ad",
//            CustomNativeAdFactory(this)
//        )
//    }
//
//    override fun onDestroy() {
//        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "custom_native_ad")
//        super.onDestroy()
//    }
//}
