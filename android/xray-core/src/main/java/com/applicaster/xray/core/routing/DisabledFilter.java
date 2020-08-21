package com.applicaster.xray.core.routing;

import androidx.annotation.NonNull;

public class DisabledFilter implements ISinkFilter {
    @Override
    public boolean accept(@NonNull String loggerName, @NonNull String tag, int level) {
        return false;
    }
}
