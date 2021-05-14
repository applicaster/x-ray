package com.applicaster.xray.android.sinks;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.applicaster.xray.core.Event;
import com.applicaster.xray.core.ISink;
import com.applicaster.xray.core.formatting.event.IEventFormatter;
import com.applicaster.xray.core.formatting.event.PlainTextEventFormatter;

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
    private final long fileSizeLimit;
    private IEventFormatter formatter = new PlainTextEventFormatter();

    public PackageFileLogSink(@NonNull Context ctx,
                              @NonNull String fileName) {
        this.fileName = fileName;
        this.ctx = ctx.getApplicationContext();
        fileSizeLimit = -1;
    }

    public PackageFileLogSink(@NonNull Context ctx,
                              @NonNull String fileName,
                              long fileSizeLimit) {
        this.fileName = fileName;
        this.ctx = ctx.getApplicationContext();
        this.fileSizeLimit = fileSizeLimit;
    }


    public ISink setFormatter(@NonNull IEventFormatter formatter) {
        synchronized(this) {
            this.formatter = formatter;
        }
        return this;
    }

    @NonNull
    public File getFile() {
        return ctx.getApplicationContext().getFileStreamPath(fileName);
    }

    private void writeToFile(@NonNull String msg) {
        int mode = (fileSizeLimit > 0 && getFile().length() > fileSizeLimit)
                ? 0 : Context.MODE_APPEND;
        if(0 == mode) {
            Log.i(TAG, "File log " + fileName + " was truncated due to reaching size limit " + fileSizeLimit);
        }
        // open the file every time for now to avoid issues with sudden process termination (can just flush though)
        try (FileOutputStream trace = ctx.openFileOutput(fileName, mode)){
            trace.write(msg.getBytes());
        } catch (IOException ioe) {
            // todo: where logger logs logging errors?
            Log.e(TAG, "Error writing to " + fileName, ioe);
        }
    }

    @Override
    public void log(@NonNull Event event) {
        synchronized(this) {
            writeToFile(formatter.format(event));
        }
    }
}
