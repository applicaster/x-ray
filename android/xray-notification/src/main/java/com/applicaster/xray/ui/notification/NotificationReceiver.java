package com.applicaster.xray.ui.notification;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

/**
 * Dummy class to receive intents that are not handled by anyone else.
 * Can be used later to handle some additional internal actions.
 */
public class NotificationReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        Log.d("NotificationReceiver", "Intent action " + intent.getAction());
    }

    private static final int requestCode = 1;

    public static PendingIntent getIntent(Context context, String action) {
        return PendingIntent.getBroadcast(
                context,
                requestCode,
                new Intent(context, NotificationReceiver.class).setAction(action),
                PendingIntent.FLAG_CANCEL_CURRENT);
    }
}
