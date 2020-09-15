package com.applicaster.xray.android.adapters;

import com.applicaster.xray.core.Logger;

/**
 * Auto-replace wrapper for Android default logging functions
 * Just replace imports and calls to Log.e( to ALog.e(, etc or use replace regex, if IDE allows it
 */
public class ALog {

    private static Logger log = Logger.get("ALog");

    public static void v(String tag, String message) {
        log.v(tag).message(message);
    }

    public static void v(String tag, String message, Throwable throwable) {
        log.v(tag).exception(throwable).message(message);
    }

    public static void d(String tag, String message) {
        log.d(tag).message(message);
    }

    public static void d(String tag, String message, Throwable throwable) {
        log.d(tag).exception(throwable).message(message);
    }

    public static void i(String tag, String message) {
        log.i(tag).message(message);
    }

    public static void i(String tag, String message, Throwable throwable) {
        log.i(tag).exception(throwable).message(message);
    }

    public static void w(String tag, String message) {
        log.w(tag).message(message);
    }

    public static void w(String tag, String message, Throwable throwable) {
        log.w(tag).exception(throwable).message(message);
    }

    public static void e(String tag, String message) {
        log.e(tag).message(message);
    }

    public static void e(String tag, String message, Throwable throwable) {
        log.e(tag).exception(throwable).message(message);
    }
}
