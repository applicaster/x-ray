package com.applicaster.xray.core.formatting.event;

import androidx.annotation.NonNull;

import com.applicaster.xray.core.Event;

public interface IEventFormatter {
    @NonNull
    String format(@NonNull Event event);
}
