package com.applicaster.xray.example

import android.app.Application
import android.app.PendingIntent
import android.content.Intent
import com.applicaster.xray.android.contexts.ThreadContext
import com.applicaster.xray.android.routing.DefaultSinkFilter
import com.applicaster.xray.android.sinks.ADBSink
import com.applicaster.xray.android.sinks.PackageFileLogSink
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.core.Logger
import com.applicaster.xray.crashreporter.Reporting
import com.applicaster.xray.crashreporter.SendActivity
import com.applicaster.xray.ui.sinks.InMemoryLogSink
import com.applicaster.xray.example.ui.MainActivity
import com.applicaster.xray.formatters.message.reflactionformatter.ReflectionMessageFormatter
import com.applicaster.xray.ui.notification.XRayNotification

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        initXRay()
    }

    companion object {
        const val memory_sink_name = "memory_sink" // used in EventLogFragment sink_name field
    }

    private fun initXRay() {

        val fileLogSink =
            PackageFileLogSink(
                this,
                "default.log",
                256 * 1024
            )
        val errorFileLogSink =
            PackageFileLogSink(
                this,
                "errors.log"
            )

        // Here you can use fileLogSink.getFile() to connect log file to crash reporting module:
        // Its also possible to provide file name to the SendActivity intent directly
        Reporting.init("crash@example.com", fileLogSink.file)
        Reporting.enableForCurrentThread(this, true)

        // configure XRay notification

        // add log view and report sharing buttons
        val shareLogIntent = SendActivity.getSendPendingIntent(this)
        val showLogIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java)
                .setFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT or Intent.FLAG_ACTIVITY_CLEAR_TASK),
            PendingIntent.FLAG_CANCEL_CURRENT
        )!!

        // actions order is kept in the UI
        val actions: HashMap<String, PendingIntent> = linkedMapOf(
            "Send" to shareLogIntent,
            "Show" to showLogIntent)

        // here we show Notification UI with custom actions
        XRayNotification.show(
            this,
            101,
            null,
            actions
        )

        Core.get()
            .addSink("adb_sink", ADBSink())
            .addSink(
                memory_sink_name,
                InMemoryLogSink()
            )
            .addSink("default_log_sink", fileLogSink)
            .addSink("error_log_sink", errorFileLogSink)
            .setFilter("error_log_sink", "", DefaultSinkFilter(LogLevel.error))

        val rootLogger = Logger.get()
        rootLogger.setContext(ThreadContext())
        rootLogger.setFormatter(ReflectionMessageFormatter())
    }
}