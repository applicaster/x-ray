package com.applicaster.xray.android.contexts;

import com.applicaster.xray.core.LogContext;

import org.jetbrains.annotations.NotNull;

import java.util.Map;

public class ThreadContext extends LogContext {

    @NotNull
    @Override
    public Map<String, Object> retrieve() {
        Map<String, Object> retrieve = super.retrieve();
        retrieve.put("thread_id", Thread.currentThread().getId());
        retrieve.put("thread_name", Thread.currentThread().getName());
        return retrieve;
    }

}
