package com.applicaster.xray.core

import java.util.*

open class LogContext() : HashMap<String, Any?>(){

    constructor(logContext: Map<String, Any?>): this() {
        this.putAll(logContext)
    }

    open fun retrieve(): Map<String, Any?>{
        return this
    }
}