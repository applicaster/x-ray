package com.applicaster.xray.ui.utility

import com.applicaster.xray.core.Event
import com.google.gson.Gson
import com.google.gson.GsonBuilder

object GsonHolder {
    val gson: Gson by lazy { GsonBuilder().create() }
}

fun Event.format(): CharSequence? =
    GsonHolder.gson.toJson(this)
