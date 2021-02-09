package com.applicaster.xray.reactnative

import com.applicaster.xray.core.Core
import com.applicaster.xray.core.Event
import com.applicaster.xray.core.Logger
import com.facebook.react.bridge.*
import java.util.*

class XRayLoggerBridge(reactContext: ReactApplicationContext)
    : ReactContextBaseJavaModule(reactContext) {

    private val logger = Logger.get(NAME)

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
        if (!Core.get().hasSinks(category, subsystem, level)) {
            return
        }
        val message = eventData.getString("message")
        if(null == message) {
            logger.e(NAME).message("Null message was passed")
        }
        val event = Event(
                category,
                subsystem,
                System.currentTimeMillis(),
                level,
                message ?: "null",
                optHashMap(eventData, "data"),
                optHashMap(eventData, "context"),
                null
        )
        Core.get().submit(event)
    }

    private fun optHashMap(eventData: ReadableMap, key: String): HashMap<String, Any>? {
        if (!eventData.hasKey(key)) {
            return null
        }
        val type = eventData.getType(key)
        return when {
            ReadableType.Null == type -> null
            ReadableType.Map != type -> {
                logger.e(NAME).message(
                        "Wrong data type was passed to X-Ray bridge in $key field: expected Map, got $type." +
                                " $key will be omitted from the log record.")
                null
            }
            else -> eventData.getMap(key)?.toHashMap()
        }
    }
}