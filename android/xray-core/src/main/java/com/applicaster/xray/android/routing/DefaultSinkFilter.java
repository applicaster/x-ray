package com.applicaster.xray.android.routing;

import androidx.annotation.NonNull;

import com.applicaster.xray.core.LogLevel;
import com.applicaster.xray.core.routing.ISinkFilter;

import org.jetbrains.annotations.NotNull;

public class DefaultSinkFilter implements ISinkFilter {

    private int minLevel;

    public DefaultSinkFilter(@NotNull LogLevel level) {
        minLevel = level.level;
    }

    @Override
    public boolean accept(@NonNull String loggerName, @NonNull String tag, int level) {
        return minLevel <= level;
    }
}
