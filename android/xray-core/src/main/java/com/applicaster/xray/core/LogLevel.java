package com.applicaster.xray.core;

import androidx.annotation.NonNull;

/**
 * Log level constants. These are kept in sync between platforms.
 * Enum is used in used in external API where possible
 */
public enum LogLevel {
    verbose(0),
    debug(1),
    info(2),
    warning(3),
    error(4);

    public final int level;

    LogLevel(int level) {
        this.level = level;
    }

    @NonNull
    public static LogLevel fromLevel(int level) {
        for (LogLevel value : LogLevel.values()) {
            if(value.level == level) {
                return value;
            }
        }
        return error; // maximum we have
    }
}
