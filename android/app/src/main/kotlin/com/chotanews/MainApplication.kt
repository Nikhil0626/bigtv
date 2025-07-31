package com.chotanews

import android.app.Application

import com.webengage.sdk.android.LocationTrackingStrategy
import com.webengage.sdk.android.WebEngageConfig
import com.webengage.sdk.android.actions.database.ReportingStrategy
import com.webengage.webengage_plugin.WebengageInitializer

class MainApplication : Application() {

    override fun onCreate() {
        super.onCreate()
        // Initialize WebEngage
        val webEngageConfig = WebEngageConfig.Builder()
            .setWebEngageKey("in~~1341061ba")
            .setEventReportingStrategy(ReportingStrategy.FORCE_SYNC)
            .setAutoGCMRegistrationFlag(false)
            .setLocationTrackingStrategy(LocationTrackingStrategy.ACCURACY_BEST)
            .setDebugMode(true) // only in development mode
            .build()
        WebengageInitializer.initialize(this, webEngageConfig)

    }
}