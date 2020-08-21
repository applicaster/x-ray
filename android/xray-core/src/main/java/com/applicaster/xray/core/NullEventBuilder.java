package com.applicaster.xray.core;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.jetbrains.annotations.NotNull;

import java.util.Map;

public class NullEventBuilder implements IEventBuilder {
    @Override
    public Event build() {
        // should not be called
        return null;
    }

    @NotNull
    @Override
    public IEventBuilder setLevel(int level) {
        return this;
    }

    @NotNull
    @Override
    public IEventBuilder exception(@NotNull Throwable t) {
        return this;
    }

    @NotNull
    @Override
    public IEventBuilder putData(@NotNull Map<String, ?> data) {
        return this;
    }

    @NonNull
    @Override
    public IEventBuilder expandData() {
        return this;
    }

    @NotNull
    @Override
    public IEventBuilder withCallStack() {
        return this;
    }

    @Override
    public void message(@NonNull String message) {
        // ignore
    }

    @Override
    public void message(@NonNull String message, @Nullable Object... args) {
        // ignore
    }
}
