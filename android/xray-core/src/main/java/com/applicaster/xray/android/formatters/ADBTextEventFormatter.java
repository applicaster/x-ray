package com.applicaster.xray.android.formatters;

import androidx.annotation.NonNull;

import com.applicaster.xray.core.Event;
import com.applicaster.xray.core.formatting.event.IEventFormatter;

import java.util.Map;

public class ADBTextEventFormatter implements IEventFormatter {

    @NonNull
    @Override
    public String format(@NonNull Event event) {
        StringBuilder sb = new StringBuilder(event.getCategory())
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
