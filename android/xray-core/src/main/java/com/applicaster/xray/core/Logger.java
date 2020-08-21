package com.applicaster.xray.core;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.applicaster.xray.core.formatting.message.BasicMessageFormatter;
import com.applicaster.xray.core.formatting.message.IMessageFormatter;
import com.applicaster.xray.core.utility.Stack;

import org.jetbrains.annotations.NotNull;

import java.util.HashMap;
import java.util.Map;

public class Logger {

    public static final char NameSeparator = '/';

    private final HashMap<String, Logger> children = new HashMap<>();

    private final String name;

    private final Logger parent;

    private LogContext context = new LogContext();

    private IMessageFormatter messageFormatter;

    private static final Logger sRoot = new Logger("", null);

    public IEventBuilder v() {
        return v(getStackTag());
    }

    public IEventBuilder i() {
        return i(getStackTag());
    }

    public IEventBuilder d() {
        return d(getStackTag());
    }

    public IEventBuilder w() {
        return w(getStackTag());
    }

    public IEventBuilder e() {
        return e(getStackTag());
    }

    public IEventBuilder v(@NonNull String tag) {
        return makeBuilder(tag, LogLevel.verbose);
    }

    public IEventBuilder d(@NonNull String tag) {
        return makeBuilder(tag, LogLevel.debug);
    }

    public IEventBuilder i(@NonNull String tag) {
        return makeBuilder(tag, LogLevel.info);
    }

    public IEventBuilder w(@NonNull String tag) {
        return makeBuilder(tag, LogLevel.warning);
    }

    public IEventBuilder e(@NonNull String tag) {
        return makeBuilder(tag, LogLevel.error);
    }

    @NotNull
    private IEventBuilder makeBuilder(@NonNull String tag, LogLevel level) {
        if(!Core.get().hasSinks(this.getName(), tag, level.level)) {
            return new NullEventBuilder();
        }
        return new EventBuilder(tag,
                this.getName(),
                getFullContext(),
                resolveMessageFormatter())
                .setLevel(level.level);
    }

    @NotNull
    private IMessageFormatter resolveMessageFormatter() {
        synchronized(this) {
            if (null == parent || null != messageFormatter)
                return this.messageFormatter;
        }
        return parent.resolveMessageFormatter();
    }

    @NotNull
    public Map<String, Object> getFullContext() {
        Map<String, Object> mergedContext = new HashMap<>();
        if (parent != null) {
            mergedContext.putAll(parent.getFullContext());
        }
        // override parent values on conflict
        synchronized(this) {
            mergedContext.putAll(context.retrieve());
        }
        return mergedContext;
    }

    @NotNull
    public synchronized Logger setContext(@NotNull LogContext context) {
        this.context = context; // overrides context!
        return this;
    }

    @NonNull
    private String getStackTag() {
        StackTraceElement[] stackTrace = Thread.currentThread().getStackTrace();
        int frameOffset = Stack.getClientCodeFrameOffset(stackTrace);
        if(frameOffset >= 0 && frameOffset < stackTrace.length) {
            return stackTrace[frameOffset].getClassName();
        }
        return "Undefined";
    }

    private Logger(@NonNull String name,
                   @Nullable Logger parent) {
        this.name = name;
        this.parent = parent;
        if(null == parent) {
            messageFormatter = new BasicMessageFormatter();
        }
    }

    @NotNull
    public static synchronized Logger get() {
        return sRoot;
    }

    @NotNull
    public synchronized Logger getChild(@NonNull String childName) {
        int sep = childName.indexOf(NameSeparator);
        if (-1 == sep) {
            return getOrMakeChild(childName);
        }
        String child = childName.substring(0, sep);
        String grandChild = childName.substring(sep + 1);
        return getOrMakeChild(child).getChild(grandChild);
    }

    @NotNull
    private Logger getOrMakeChild(@NonNull String childName) {
        Logger logger = children.get(childName);
        if(null != logger) {
            return logger;
        }
        logger = new Logger(name.isEmpty() ? childName : name + NameSeparator + childName, this);
        children.put(childName, logger);
        return logger;
    }

    @NotNull
    public static synchronized Logger get(@NonNull String name) {
        return sRoot.getChild(name);
    }

    @NotNull
    public String getName() {
        return name;
    }

    @NotNull
    public Logger setFormatter(@NotNull IMessageFormatter formatter) {
        synchronized (this) {
            this.messageFormatter = formatter;
        }
        return this;
    }

}
