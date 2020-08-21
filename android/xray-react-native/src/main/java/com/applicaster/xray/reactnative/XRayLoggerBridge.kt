package com.applicaster.xray.reactnative

import com.applicaster.xray.core.Core
import com.applicaster.xray.core.Event
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap

class XRayLoggerBridge(reactContext: ReactApplicationContext)
    : ReactContextBaseJavaModule(reactContext) {

    companion object {
        private const val NAME = "XRayLoggerBridge"
    }

    override fun getName(): String {
        return NAME
    }

    @ReactMethod
    fun logEvent(eventData: ReadableMap) {
        val category = eventData.getString("category")!!
        val subsystem = eventData.getString("subsystem")!!
        val level = eventData.getInt("level")
        if(!Core.get().hasSinks(category, subsystem, level)) {
            return
        }
        val event = Event(
            category,
            subsystem,
            System.currentTimeMillis(),
            level,
            eventData.getString("message")!!,
            optHashMap(eventData,"data"),
            optHashMap(eventData,"context"),
            null
        )
        Core.get().submit(event)
    }

    private fun optHashMap(eventData: ReadableMap, key: String) =
        if (eventData.hasKey(key)) eventData.getMap(key)?.toHashMap() else null
}