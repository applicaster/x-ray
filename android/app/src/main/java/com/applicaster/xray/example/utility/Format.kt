package com.applicaster.xray.example.utility

import com.applicaster.xray.core.Event
import com.google.gson.GsonBuilder

private object GsonHolder {
    val gson by lazy { GsonBuilder().create() }
}

fun Event.format(): CharSequence? =
    GsonHolder.gson.toJson(this)
