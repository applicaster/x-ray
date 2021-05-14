package com.applicaster.xray.crashreporter;

import android.content.Context;

import androidx.annotation.NonNull;

import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.Thread.UncaughtExceptionHandler;

public class DelayedTopExceptionHandler extends BaseTopExceptionHandler {

    public static final String STACK_TRACE_FILE = "stack.trace";

    public DelayedTopExceptionHandler(Context ctx) {
        super(ctx);
    }

    public void uncaughtException(@NonNull Thread t, @NonNull Throwable e) {
        StringBuilder report = dumpException(t, e);
        try(FileOutputStream trace = context.openFileOutput(STACK_TRACE_FILE, Context.MODE_PRIVATE)) {
            trace.write(report.toString().getBytes());
        } catch (IOException ioe) {
            // ignored
        }
        defaultUEH.uncaughtException(t, e);
    }

}
