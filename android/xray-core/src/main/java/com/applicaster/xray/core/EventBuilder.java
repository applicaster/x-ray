package com.applicaster.xray.core;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.applicaster.xray.core.formatting.message.IMessageFormatter;
import com.applicaster.xray.core.utility.Stack;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


public class EventBuilder implements IEventBuilder {
    private final String category;
    private final long timestamp;
    private final Map<String, Object> context;
    private final String subsystem;
    private final IMessageFormatter messageFormatter;
    private LinkedHashMap<String, Object> data = new LinkedHashMap<>();
    private int level;
    private String message;
    private Throwable exception;
    private boolean expandData; // todo: covert objects to Map/Array or other convenient container if set

    private boolean submitted;

    public EventBuilder(@NonNull String category,
                        @NonNull String subsystem,
                        @NonNull Map<String, Object> context,
                        @NonNull IMessageFormatter messageFormatter) {
        this.category = category;
        this.subsystem = subsystem;
        this.messageFormatter = messageFormatter;
        this.timestamp = System.currentTimeMillis();
        this.context = context;
    }

    @Override
    public Event build() {
        // todo: handle expandData
        return new Event(
                category,
                subsystem,
                timestamp,
                level,
                message,
                data,
                context,
                exception);
    }

    @Override
    @NotNull
    public IEventBuilder setLevel(int level) {
        this.level = level;
        return this;
    }

    @NotNull
    @Override
    public IEventBuilder exception(@NotNull Throwable t) {
        this.exception = t;
        return this;
    }

    @Override
    @NotNull
    public IEventBuilder putData(@NotNull Map<String, ?> data) {
        this.data.putAll(data);
        return this;
    }

    // Expand data to primitive classes. toString will be used otherwise
    @Override
    @NonNull
    public IEventBuilder expandData() {
        this.expandData = true;
        return this;
    }

    @Override
    public void message(@NonNull String message) {
        this.message = message;
        submit();
    }

    @Override
    public void message(@NonNull String message,
                        @Nullable Object... args) {
        this.message = messageFormatter.format(message, data, args);
        submit();
    }

    private void submit() {
        Core.get().submit(build());
        submitted = true;
    }

    private void internalError(@NonNull String message) {

    }

    @Override
    @NotNull
    public IEventBuilder withCallStack() {
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        int frameOffset = Stack.getClientCodeFrameOffset(stackTrace);
        List<String> stack = new ArrayList<>();
        for (int i = frameOffset; i < stackTrace.length; i++) {
            StackTraceElement stackTraceElement = stackTrace[i];
            stack.add(stackTraceElement.toString() + '\n');
        }
        context.put("stackTrace", stack);
        return this;
    }

}
