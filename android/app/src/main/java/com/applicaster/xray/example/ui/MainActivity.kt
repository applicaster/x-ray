package com.applicaster.xray.example.ui

import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity
import com.applicaster.xray.android.routing.DefaultSinkFilter
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.LogContext
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.core.Logger
import com.applicaster.xray.crashreporter.Reporting
import com.applicaster.xray.example.R
import com.applicaster.xray.example.model.JavaTestClass
import com.applicaster.xray.example.model.KotlinTestClass
import com.applicaster.xray.formatters.message.reflactionformatter.NamedReflectionMessageFormatter

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        findViewById<Button>(R.id.btn_log_some).setOnClickListener { logSomeEvents() }
        findViewById<Button>(R.id.btn_crash).setOnClickListener { throw Exception("Test crash") }
        // now when UI is ready, we can check for crash report
        Reporting.checkCrashReport(this)
    }

    private fun logSomeEvents() {
        val rootLogger = Logger.get()
        val kotlinTestClass = KotlinTestClass(
            "String field",
            0xff,
            0.1f
        )
        val javaTestClass = JavaTestClass(
            "String field",
            0xff,
            0.1f
        )

        rootLogger
            .d("Test")
            .message("Basic debug message")

        rootLogger
            .i("Test")
            .message("Basic info message")

        rootLogger
            .w("Test")
            .message("Basic warning message")

        rootLogger
            .e("Test")
            .exception(Exception("Error", Exception("Cause")))
            .message("Basic error message")

        rootLogger
            .d() // auto tag with enclosing class name
            .putData(mapOf("object" to kotlinTestClass))
            .message(
                "Formatter test for Kotlin class %s&object_contents",
                kotlinTestClass
            )

        rootLogger
            .d() // auto tag with enclosing class name
            .putData(mapOf("object" to kotlinTestClass))
            .message(
                "Formatter test for Kotlin class %s",
                kotlinTestClass
            )

        rootLogger
            .d("Test")
            .message(
                "Formatter test for Kotlin class %s",
                kotlinTestClass
            )

        rootLogger
            .d("Test")
            .message(
                "Formatter test for Java class %s",
                javaTestClass
            )

        rootLogger
            .d("Test")
            .message(
                "Formatter test for Java and Kotlin classes with positional args. Java: %1\$s, Kotlin: %2\$s",
                javaTestClass,
                kotlinTestClass
            )

        // create a child logger
        val childLogger = rootLogger.getChild("childLogger");

        // configure child logger: set custom formatter and append context
        childLogger
            .setFormatter(NamedReflectionMessageFormatter()) // this will extract log arguments as a named key value pairs to the event
            .setContext(LogContext(mapOf("loggerContext" to "loggerContextValue")));

        Core.get()
            .setFilter("error_log_sink", "childLogger", DefaultSinkFilter(LogLevel.debug))

        rootLogger
            .d("Test")
            .withCallStack()
            .message(
                "Logging debug to root"
            )

        rootLogger
            .e("Test")
            .withCallStack()
            .message(
                "Logging error to root"
            )

        childLogger
            .d("Test")
            .withCallStack()
            .message(
                "Logging debug to child"
            )

        childLogger
            .e("Test")
            .withCallStack()
            .message(
                "Logging error to child"
            )

        // use child logger
        childLogger
            .d("Test")
            .withCallStack()
            .message(
                "Formatter test for Java and Kotlin classes with extracted positional args. Java: %1\$s&java_object, Kotlin: %2\$s&kotlin_object",
                javaTestClass,
                kotlinTestClass
            )
    }
}
