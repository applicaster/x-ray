package com.applicaster.xray.ui.notification

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.LogLevel


object XRayNotification {

    private const val ERROR_COUNTER_SINK_NAME = "error_counter_sink"
    private const val CHANNEL_ID = "xray.notification"
    private val CHANNEL_NAME: CharSequence = "X Ray logging"

    private const val requestCode = 1

    private var currentNotificationId = -1
    private var channelCreated = false

    private var errors = 0;
    private var warnings = 0;

    fun show(context: Context,
             notificationId: Int,
             pi: PendingIntent? = null,
             actions: Map<String, PendingIntent>? = null) {
        if (-1 != currentNotificationId) {
            hide(context)
        }
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (!channelCreated) {
            // create android channel
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    CHANNEL_NAME,
                    NotificationManager.IMPORTANCE_DEFAULT
                )
                channel.enableLights(false)
                channel.enableVibration(false)
                channel.importance = NotificationManager.IMPORTANCE_MIN
                channel.setSound(null, null)
                channel.setShowBadge(false)
                channel.lockscreenVisibility = Notification.VISIBILITY_SECRET
                notificationManager.createNotificationChannel(channel)
            }
            channelCreated = true
        }

        val notificationBuilder =
                NotificationCompat.Builder(context, CHANNEL_ID)
                        .setSmallIcon(R.drawable.ic_xray_notification)
                        .setLargeIcon(
                                BitmapFactory.decodeResource(
                                        context.resources,
                                        R.drawable.ic_xray_notification
                                )
                        )
                        .setContentTitle("X-Ray logger")
                        .setOnlyAlertOnce(true)
                        .setContentIntent(pi
                                ?: NotificationReceiver.getIntent(context, "com.applicaster.xray.show.ui"))
                        .setAutoCancel(false)
                        .setShowWhen(false)
                        .setSound(null)

        actions?.forEach {
            notificationBuilder.addAction(0, it.key, it.value)
        }

        addErrorCounter(notificationBuilder, notificationManager, notificationId)

        notificationManager.notify(notificationId, notificationBuilder.build())
        currentNotificationId = notificationId
    }

    // Does not guarantee that notification is visible, only that the feature is enabled.
    // User could had it dismissed, but it will pop up back on next warning or error
    fun isShowing() = currentNotificationId != -1

    fun hide(context: Context) {
        if (-1 == currentNotificationId) {
            return
        }
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(currentNotificationId)
        Core.get().removeSink(ERROR_COUNTER_SINK_NAME)
        currentNotificationId = -1
    }

    private fun addErrorCounter(
        notificationBuilder: NotificationCompat.Builder,
        notificationManager: NotificationManager,
        notificationId: Int
    ) {
        val uiHandler = Handler(Looper.getMainLooper())
        // must be Runnable so removeCallbacks will work
        val printErrors = Runnable {
            // https://emojipedia.org/prohibited/
            // https://emojipedia.org/warning/
            notificationBuilder.setContentText("\uD83D\uDEAB$errors \u26A0\uFE0F$warnings️")
            notificationManager.notify(notificationId, notificationBuilder.build())
        }

        Core.get().addSink(ERROR_COUNTER_SINK_NAME) { event ->
            when (event.level) {
                LogLevel.error.level -> ++errors
                LogLevel.warning.level -> ++warnings
                else -> return@addSink
            }
            // remove old runnable in case we have more than one error in single ui loop update
            uiHandler.removeCallbacks(printErrors)
            uiHandler.postDelayed(printErrors, 10) // delay a bit in case errors will come in batch
        }
    }

}