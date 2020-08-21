package com.applicaster.xray.core.routing;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.applicaster.xray.core.ISink;
import com.applicaster.xray.core.Logger;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/*
  Maps loggers to sinks using rules. Not thread safe
 */
public class Mapper {

    // sinks Set is be backed up by original map owned by Core
    private final Set<String> sinks;
    // map Logger subsystem -> (sink identifier -> sink filter)
    private final Map<String, HashMap<String, ISinkFilter>> loggerMapping = new HashMap<>();

    public Mapper(Map<String, ISink> sinks) {
        this.sinks = sinks.keySet();
    }

    public void setFilter(@NonNull final String loggerName,
                          @NonNull final String sinkName,
                          @Nullable final ISinkFilter filter) {
        synchronized (loggerMapping) {
            HashMap<String, ISinkFilter> mappedSinks = loggerMapping.get(loggerName);
            if (null != mappedSinks) {
                if(null != filter) {
                    mappedSinks.put(sinkName, filter);
                } else {
                    mappedSinks.remove(sinkName);
                    if(mappedSinks.isEmpty()) {
                        loggerMapping.remove(loggerName);
                    }
                }
                return;
            }
            if(null == filter) {
                return;
            }
            loggerMapping.put(loggerName, new HashMap<String, ISinkFilter>() {{
                put(sinkName, filter);
            }});
        }
    }

    @Nullable
    private HashMap<String, ISinkFilter> getClosestMapping(@NonNull String logger) {
        if(logger.isEmpty()) {
            return loggerMapping.get(""); // root logger mapping
        }
        // exact match
        HashMap<String, ISinkFilter> mappedSinks = loggerMapping.get(logger);
        if(null != mappedSinks) {
            // should not be empty
            return mappedSinks;
        }
        // look for any parent mapping
        int i = logger.lastIndexOf(Logger.NameSeparator);
        while(i > 0) {
            String parent = logger.substring(0, i);
            mappedSinks = loggerMapping.get(parent);
            if(null != mappedSinks) {
                return mappedSinks;
            }
            logger = parent;
            i = logger.lastIndexOf(Logger.NameSeparator);
        }
        return loggerMapping.get(""); // root logger mapping
    }

    public Set<String> getMapping(@NonNull String logger,
                                  @NonNull String tag,
                                  int level) {
        HashSet<String> result;
        synchronized (sinks) {
            result = new HashSet<>(this.sinks);
        }
        HashMap<String, ISinkFilter> mappedSinks;
        synchronized (loggerMapping) {
            mappedSinks = getClosestMapping(logger);
        }
        if (mappedSinks == null) {
            return result;
        }
        for (Map.Entry<String, ISinkFilter> mappedSink : mappedSinks.entrySet()) {
            if (null != mappedSink.getValue() && !mappedSink.getValue().accept(logger, tag, level)) {
                result.remove(mappedSink.getKey());
            }
        }
        return result;
    }

    public boolean hasSinks(@NonNull String loggerName,
                            @NonNull String tag,
                            int level) {
        // todo: optimize
        return !getMapping(loggerName, tag, level).isEmpty();
    }

    public void reset() {
        synchronized (loggerMapping) {
            loggerMapping.clear();
        }
    }
}
