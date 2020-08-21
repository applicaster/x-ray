package com.applicaster.xray.core.formatting.event;

import android.text.format.DateFormat;

import androidx.annotation.NonNull;

import com.applicaster.xray.core.Event;
import com.applicaster.xray.core.LogLevel;

import java.util.Map;

public class PlainTextEventFormatter implements IEventFormatter {

    // todo: add format string option

    @NonNull
    @Override
    public String format(@NonNull Event event) {
        StringBuilder sb = new StringBuilder()
                .append(DateFormat.format("yyyy-MM-dd HH:mm:ss", event.getTimestamp())).append(" ")
                .append(LogLevel.fromLevel(event.getLevel()).name()).append(" ")
                .append(event.getCategory()).append(" ")
                .append(event.getSubsystem()).append(" ")
                .append(event.getMessage())
                .append("\n");
        Map<String, Object> data = event.getData();
        if(null != data && !data.isEmpty()) {
            sb.append("\n\tdata: ").append(data).append("\n");
        }
        Map<String, Object> context = event.getContext();
        if(null != context && !context.isEmpty()) {
            sb.append("\n\tcontext: ").append(context).append("\n");
        }
        return sb.toString();
    }
}
