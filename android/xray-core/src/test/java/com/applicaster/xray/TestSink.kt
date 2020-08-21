package com.applicaster.xray

import com.applicaster.xray.core.Event
import com.applicaster.xray.core.ISink
import org.junit.Assert
import java.util.ArrayDeque

class TestSink(val name: String) : ISink {

    private val deque = ArrayDeque<String>()

    fun addExpectedMessage(message: String) {
        deque.push(message)
    }

    override fun log(event: Event) {
        Assert.assertFalse(
            "Sink $name expects log output",
            deque.isEmpty()
        )
        Assert.assertEquals(
            "Sink $name expects message ${event.message}",
            deque.pop(),
            event.message
        )
    }

    fun isEmpty() = deque.isEmpty()
}