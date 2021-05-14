package com.applicaster.xray.core.formatting.message;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;

public interface IMessageFormatter {
    // can follow different
    @NonNull
    String format(@NonNull String template,
                  @Nullable Map<String, Object> outParameters,
                  @Nullable Object... args);
}
