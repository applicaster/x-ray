package com.applicaster.xray.example.utility

import com.applicaster.xray.core.Event
import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.JsonReader
import com.squareup.moshi.JsonWriter
import com.squareup.moshi.Moshi
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory

private object MoshiFormatter {

    private val moshi: Moshi = Moshi.Builder()
        .add(KotlinJsonAdapterFactory())
        .add(StackTraceElement::class.java, object : JsonAdapter<StackTraceElement>() {
            override fun toJson(writer: JsonWriter, value: StackTraceElement?) {
                if(null == value) {
                    writer.nullValue()
                    return
                }
                writer.beginObject()
                writer.name("fileName").value(value.fileName)
                writer.name("className").value(value.className)
                writer.name("methodName").value(value.methodName)
                writer.name("lineNumber").value(value.lineNumber)
                writer.endObject()
            }
            override fun fromJson(reader: JsonReader): StackTraceElement? {
                throw Exception("Can not deserialize StackTraceElement from json")
            }
        })
        .add(Throwable::class.java, object : JsonAdapter<Throwable>() {
            override fun toJson(writer: JsonWriter, value: Throwable?) {
                if(null == value) {
                    writer.nullValue()
                    return
                }

                writer.beginObject()

                // message
                writer.name("message").value(value.message)

                // stack
                writer.name("stack").beginArray()
                val token = writer.beginFlatten()
                val stackAdapter = moshi().adapter<StackTraceElement>(StackTraceElement::class.java)
                for (it in value.stackTrace) {
                    stackAdapter.toJson(writer, it)
                }
                writer.endFlatten(token)
                writer.endArray()

                // cause
                writer.name("cause")
                this.toJson(writer, value.cause)

                writer.endObject()
            }
            override fun fromJson(reader: JsonReader): Throwable? {
                throw Exception("Can not deserialize Throwable from json")
            }
        })
        .build()

    private fun moshi() = moshi

    val eventAdapter = moshi.adapter(Event::class.java)!!
}

fun Event.format(): CharSequence? =
    MoshiFormatter.eventAdapter.toJson(this)
