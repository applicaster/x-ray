package com.applicaster.xray.crashreporter;

import android.content.Context;

import androidx.annotation.NonNull;

import org.jetbrains.annotations.NotNull;

public abstract class BaseTopExceptionHandler implements Thread.UncaughtExceptionHandler {

    protected final Context context;
    protected final Thread.UncaughtExceptionHandler defaultUEH;

    public BaseTopExceptionHandler(@NonNull Context ctx) {
        defaultUEH = Thread.getDefaultUncaughtExceptionHandler();
        context = ctx.getApplicationContext();
    }

    @NotNull
    protected StringBuilder dumpException(Thread t, @NonNull Throwable e) {
        StackTraceElement[] arr = e.getStackTrace();
        StringBuilder report = new StringBuilder(e.toString() + "\n\n");
        report.append("--------- Stack trace ---------\n\n");
        for (StackTraceElement anArr : arr)
            report.append("    ").append(anArr.toString()).append("\n");
        report.append("-------------------------------\n\n");

        report.append("--------- Cause ---------\n\n");
        Throwable cause = e.getCause();
        if (cause != null) {
            report.append(cause.toString()).append("\n\n");
            arr = cause.getStackTrace();
            for (StackTraceElement anArr : arr)
                report.append("    ").append(anArr.toString()).append("\n");
        }
        report.append("-------------------------------\n\n");
        return report;
    }
}
