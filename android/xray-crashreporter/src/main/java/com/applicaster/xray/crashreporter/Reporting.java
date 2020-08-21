package com.applicaster.xray.crashreporter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ShareCompat;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;

public class Reporting {

    private static String email = "";
    private static File logFile;

    public static void init(@NonNull String email, @Nullable File logFile) {
        Reporting.email = email;
        Reporting.logFile = logFile;
    }

    public static void enableForCurrentThread(Context context, boolean immediate) {
        // todo: need to check that we do not call it twice for a thread
        Thread.setDefaultUncaughtExceptionHandler(immediate
                ? new ImmediateTopExceptionHandler(context)
                : new DelayedTopExceptionHandler(context));
    }

    public static void checkCrashReport(@NonNull final Activity activity) {
        StringBuilder trace = new StringBuilder();
        try(BufferedReader reader = new BufferedReader(new InputStreamReader(activity.openFileInput(DelayedTopExceptionHandler.STACK_TRACE_FILE)))) {
            String line;
            while ((line = reader.readLine()) != null)
                trace.append(line).append("\n");
        } catch (FileNotFoundException ignored) {
            return;
        } catch (IOException ioe) {
            activity.deleteFile(DelayedTopExceptionHandler.STACK_TRACE_FILE);
            return;
        }
        activity.deleteFile(DelayedTopExceptionHandler.STACK_TRACE_FILE);

        StringBuilder sb = buildReportHeader(activity);
        sb.append(trace);
        confirmSendCrashReport(activity, sb.toString());
    }

    public static void sendWithAttachment(@NonNull Activity ctx,
                                          @NonNull String body,
                                          @Nullable File attachment) {

        ShareCompat.IntentBuilder builder = ShareCompat.IntentBuilder.from(ctx);
        builder.setType("text/plain")
                .setChooserTitle("Send error report") //todo: localize?
                .setSubject("Error report") // todo append package id?
                .setText(body);

        if (!TextUtils.isEmpty(email)) {
            builder.setEmailTo(new String[]{email});
        }

        if (null != attachment && attachment.exists()) {
            // provider id is in sync with provider authorities from manifest
            Uri uri = ReportingFileProvider.getUriForFile(ctx, ctx.getPackageName() + ".reporting.provider", attachment);
            builder.setStream(uri); // uri from FileProvider
        }

        Intent intent = builder
                .getIntent()
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);

        ctx.startActivity(intent);
    }

    @NonNull
    public static StringBuilder buildReportHeader(Context ctx) {
        String model = getDeviceName();
        String versionName = "<unknown>";
        long versionCode = 0;
        try {
            PackageInfo pInfo = ctx.getPackageManager().getPackageInfo(ctx.getPackageName(), 0);
            if(null != pInfo) {
                versionName = pInfo.versionName;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    versionCode = pInfo.getLongVersionCode();
                } else {
                    versionCode = pInfo.versionCode;
                }
            }
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }

        StringBuilder sb = new StringBuilder();
        sb.append("Package: ").append(ctx.getPackageName()).append("\n");
        sb.append("Device: ").append(model).append("\n");
        sb.append("OS versionName: ").append(Build.VERSION.SDK_INT).append(Build.VERSION.CODENAME).append("\n");
        sb.append("Version name: ").append(versionName).append("\n");
        sb.append("Version code: ").append(versionCode).append("\n");
        sb.append("Report:\n");
        return sb;
    }

    @NonNull
    public static String getDeviceName() {
        String manufacturer = Build.MANUFACTURER;
        String model = Build.MODEL;
        if (model.startsWith(manufacturer))
            return model;
        else
            return manufacturer + " " + model;
    }

    public static void sendLogReport(@NonNull Activity context) {
        sendLogReport(context, logFile);
    }

    public static void sendLogReport(@NonNull Activity context, @Nullable File file) {
        StringBuilder sb = buildReportHeader(context);
        sendWithAttachment(context, sb.toString(), file);
    }

    private static void confirmSendCrashReport(@NonNull final Activity ctx,
                                               @NonNull final String body) {
        AlertDialog.Builder b = new AlertDialog.Builder(ctx);
        b.setTitle(R.string.dlg_send_crash_report_title);
        b.setMessage(R.string.dlg_send_crash_report_message);
        b.setPositiveButton(ctx.getString(android.R.string.yes),
                (dialog, which) -> sendWithAttachment(ctx, body, logFile));
        b.setNegativeButton(ctx.getString(android.R.string.cancel), null);
        b.show();
    }

    // send crash report without activity context or any additional confirmations
    static void sendCrashReport(@NonNull Context context, @NonNull String trace) {
        StringBuilder sb = buildReportHeader(context);
        sb.append(trace);

        // ShareCompat.IntentBuilder requires activity, so use old-way
        Intent intent = new Intent(android.content.Intent.ACTION_SEND);
        intent.setType("text/plain");
        intent.putExtra(android.content.Intent.EXTRA_EMAIL, email);
        intent.putExtra(android.content.Intent.EXTRA_SUBJECT, "Error report");
        intent.putExtra(android.content.Intent.EXTRA_TEXT, sb.toString());
        if(!(context instanceof Activity)) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        }
        // Usually, if we made till the point where file is not null,
        // app at least was able to launch, so content provider should work (Application class instance was created).
        // Otherwise, we will end up in an infinite loop trying to provide log file
        if (null != logFile && logFile.exists()) {
            // provider id is in sync with provider authorities from manifest
            Uri uri = ReportingFileProvider.getUriForFile(context, context.getPackageName() + ".reporting.provider", logFile);
            intent.putExtra(Intent.EXTRA_STREAM, uri);
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        }
        context.startActivity(intent);
    }

}
