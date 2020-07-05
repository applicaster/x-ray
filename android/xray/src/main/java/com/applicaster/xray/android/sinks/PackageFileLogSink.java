package com.applicaster.xray.android.sinks;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.applicaster.xray.core.Event;
import com.applicaster.xray.core.formatting.event.IEventFormatter;
import com.applicaster.xray.core.formatting.event.PlainTextEventFormatter;
import com.applicaster.xray.core.ISink;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

/*
  Android specific file log writer
 */
public class PackageFileLogSink implements ISink {

    private static final String TAG = "FileLogSink";
    private final Context ctx;
    private final String fileName;
    private final IEventFormatter formatter = new PlainTextEventFormatter();

    public PackageFileLogSink(@NonNull Context ctx,
                              @NonNull String fileName) {
        this.fileName = fileName;
        this.ctx = ctx.getApplicationContext();
    }

    @NonNull
    public File getFile() {
        return ctx.getApplicationContext().getFileStreamPath(fileName);
    }

    private synchronized void writeToFile(@NonNull String msg) {
        // open the file every time for now to avoid issues with sudden process termination
        try (FileOutputStream trace = ctx.openFileOutput(fileName, Context.MODE_APPEND)){
            trace.write(msg.getBytes());
        } catch (IOException ioe) {
            // todo: where logger logs logging errors?
            Log.e(TAG, "Error writing to " + fileName, ioe);
        }
    }

    @Override
    public void log(@NonNull Event event) {
        writeToFile(formatter.format(event));
    }
}
