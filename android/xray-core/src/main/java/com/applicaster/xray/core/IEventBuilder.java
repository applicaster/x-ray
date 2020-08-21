package com.applicaster.xray.core;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import org.jetbrains.annotations.NotNull;

import java.util.Map;

public interface IEventBuilder {

    // DummyEventBuilder will return null here
    // Maybe method should be protected or even private (i.e. not in the interface)
    // its only called from message()
    Event build();

    @NotNull
    IEventBuilder setLevel(int level);

    @NotNull
    IEventBuilder exception(@NotNull Throwable t);

    @NotNull
    IEventBuilder putData(@NotNull Map<String, ?> data);

    // Expand data to primitive classes. toString will be used otherwise
    @NonNull
    IEventBuilder expandData();

    @NotNull
    IEventBuilder withCallStack();

    void message(@NonNull String message);

    void message(@NonNull String message,
                 @Nullable Object... args);
}
