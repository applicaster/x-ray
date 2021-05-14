package com.applicaster.xray.core;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.applicaster.xray.core.routing.ISinkFilter;
import com.applicaster.xray.core.routing.Mapper;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

public class Core {

    private static Core instance;
    // LinkedHashMap retains key order
    private final LinkedHashMap<String, ISink> sinks = new LinkedHashMap<>();

    private final Mapper mapper = new Mapper(sinks);

    // are any logging classes allowed to throw exceptions to client
    private boolean neverThrow = false;

    // region Sinks management

    @NotNull
    public Core addSink(@NotNull String name, @NotNull ISink sink) {
        synchronized(sinks) {
            if(null != sinks.put(name, sink)) {
                // todo: log error
                if(!neverThrow) {
                    throw new IllegalStateException("Sink with name '" + name + "' is already registered!");
                }
            }
        }
        return this;
    }

    @Nullable
    public ISink getSink(@NotNull String name) {
        synchronized (sinks) {
            return sinks.get(name);
        }
    }

    public void removeSink(@NotNull ISink sink) {
        synchronized(sinks) {
            sinks.values().remove(sink);
        }
    }

    public void removeSink(@NotNull String sinkName) {
        synchronized(sinks) {
            sinks.remove(sinkName);
        }
    }

    // early-exit filter
    public boolean hasSinks(@NonNull String loggerName,
                            @NonNull String tag,
                            int level) {
        synchronized (mapper) {
            return mapper.hasSinks(loggerName, tag, level);
        }
    }

    @NonNull
    public ArrayList<ISink> getMapping(@NonNull Event event) {
        ArrayList<ISink> result = new ArrayList<>();
        Set<String> enabledSinks;
        synchronized (mapper) {
            enabledSinks = mapper.getMapping(event.getSubsystem(), event.getCategory(), event.getLevel());
        }
        synchronized(sinks) {
            // keeping the sink order
            for (Map.Entry<String, ISink> namedSink : sinks.entrySet()) {
                if(enabledSinks.contains(namedSink.getKey())) {
                    result.add(namedSink.getValue());
                }
            }
        }
        return result;
    }

    public Core setFilter(@NotNull String sinkName,
                          @NotNull String loggerName,
                          @Nullable ISinkFilter filter) {
        // do not care if the sink already/still exists
        synchronized (mapper) {
            mapper.setFilter(loggerName, sinkName, filter);
        }
        return this;
    }

    //endregion

    public void submit(@NotNull Event event) {
        ArrayList<ISink> mapping = getMapping(event);
        if(!mapping.isEmpty()) {
            for(ISink sink : mapping)
                sink.log(event);
        }
    }

    @NonNull
    public static Core get() {
        if (null == instance) {
            synchronized (Core.class) {
                if (null == instance) {
                    instance = new Core();
                }
            }
        }
        return instance;
    }

    public void reset() {
        synchronized(sinks) {
            sinks.clear();
        }
        synchronized (mapper) {
            mapper.reset();
        }
    }
}
