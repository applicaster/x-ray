package com.applicaster.xray.core;

import androidx.annotation.NonNull;

public interface ISink {
    void log(@NonNull Event event);
}
