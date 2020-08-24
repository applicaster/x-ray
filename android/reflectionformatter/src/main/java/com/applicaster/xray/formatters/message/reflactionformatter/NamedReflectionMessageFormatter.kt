package com.applicaster.xray.formatters.message.reflactionformatter

import android.os.Build
import androidx.annotation.RequiresApi
import java.util.regex.Pattern

/*
 High cost object unpacking adapter
 */
class NamedReflectionMessageFormatter : ReflectionMessageFormatter() {

    companion object {
        const val namedPlaceholder = "%(?<idx>\\d\\\$)?([a-z])*\\d*(.\\d+)*[bhsdoxefgatn%](?<name>(&[a-zA-Z0-9_]*)?)"
        val regex = Pattern.compile(namedPlaceholder)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun format(
        template: String,
        outParameters: MutableMap<String, Any?>?,
        vararg args: Any?
    ): String {

        if (null != outParameters) {
            val matcher = regex.matcher(template)
            var i = 0
            val namedArgs = hashMapOf<String, Int>()
            while (matcher.find()) {
                val name = matcher.group("name")
                if (null != name && name.length > 1) { // first symbol is ampersand
                    val idx = matcher.group("idx")
                    if (null == idx || idx.length < 2) {
                        namedArgs[name.substring(1)] = i
                    } else {
                        // last symbol of idx is $
                        namedArgs[name.substring(1)] = idx.substring(0, idx.length - 1).toInt() - 1
                    }
                }
                ++i
            }
            namedArgs.forEach { outParameters[it.key] = args[it.value] }
        }

        return super.format(template, outParameters, *args)
    }

}
