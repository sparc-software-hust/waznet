package com.example.waznet

import android.app.Application
import dagger.hilt.android.HiltAndroidApp
import timber.log.Timber

@HiltAndroidApp
class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // log tree when in debug

        if (BuildConfig.DEBUG) Timber.plant(Timber.DebugTree())
    }
}