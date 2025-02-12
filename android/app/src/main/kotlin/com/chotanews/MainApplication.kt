package com.chotanews

import com.webengage.sdk.android.LocationTrackingStrategy
import com.webengage.sdk.android.WebEngage
import com.webengage.sdk.android.WebEngageConfig
import com.webengage.sdk.android.actions.database.ReportingStrategy
import com.webengage.webengage_plugin.WebengageInitializer
import io.flutter.app.FlutterApplication

class MainApplication : FlutterApplication() {

    override fun onCreate() {
        super.onCreate()
        val webEngageConfig = WebEngageConfig.Builder()
            .setWebEngageKey("in~~1341061ba")
            .setEventReportingStrategy(ReportingStrategy.FORCE_SYNC)
            .setAutoGCMRegistrationFlag(true)
            .setLocationTrackingStrategy(LocationTrackingStrategy.ACCURACY_BEST)
            .setDebugMode(true) // only in development mode
            .build()
        WebengageInitializer.initialize(this, webEngageConfig)

//        val webEngageConfig1 = WebEngageConfig.Builder()
//            .setDebugMode(true)
//            .build()
//
//        WebEngage.engage(applicationContext, webEngageConfig1)
    }
}