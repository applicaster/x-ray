package com.applicaster.xray.crashreporter;

import android.content.Context;

import androidx.annotation.NonNull;

public class ImmediateTopExceptionHandler extends BaseTopExceptionHandler {

    public ImmediateTopExceptionHandler(Context ctx) {
        super(ctx);
    }

    public void uncaughtException(@NonNull Thread t, @NonNull Throwable e) {
        StringBuilder report = dumpException(t, e);
        Reporting.sendCrashReport(context, report.toString());
        defaultUEH.uncaughtException(t, e);
    }

}
