package com.applicaster.xray

import com.applicaster.xray.android.routing.DefaultSinkFilter
import com.applicaster.xray.core.*
import com.applicaster.xray.core.routing.Mapper
import org.junit.Assert.*
import org.junit.Test

/**
 * Testing for mapping routines
 */
class MapperUnitTest {

    @Test
    fun testMapperRoot() {
        val testSinkDebug = TestSink("Debug")
        val testSinkError = TestSink("Error")
        Core.get()
            .addSink("test_sink_debug", testSinkDebug)
            .addSink("test_sink_error", testSinkError)
            .setFilter("test_sink_debug", "", DefaultSinkFilter(LogLevel.debug))
            .setFilter("test_sink_error", "", DefaultSinkFilter(LogLevel.error))

        val debugMessage = "debug message"
        testSinkDebug.addExpectedMessage(debugMessage)
        Logger.get().d().message(debugMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        val errorMessage = "error message"
        testSinkDebug.addExpectedMessage(errorMessage)
        testSinkError.addExpectedMessage(errorMessage)
        Logger.get().e().message(errorMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        // run same sat on child logger
        val childLogger = Logger.get().getChild("childLogger")

        testSinkDebug.addExpectedMessage(debugMessage)
        childLogger.d().message(debugMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        testSinkDebug.addExpectedMessage(errorMessage)
        testSinkError.addExpectedMessage(errorMessage)
        childLogger.e().message(errorMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        // override error filter for child logger
        Core.get()
            .setFilter("test_sink_error", "childLogger", DefaultSinkFilter(LogLevel.debug))

        // now both sinks should receive it
        testSinkDebug.addExpectedMessage(debugMessage)
        testSinkError.addExpectedMessage(debugMessage)
        childLogger.d().message(debugMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        testSinkDebug.addExpectedMessage(errorMessage)
        testSinkError.addExpectedMessage(errorMessage)
        childLogger.e().message(errorMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        val grandChildLogger = childLogger.getChild("grandChildLogger")

        // still both should receive the message
        testSinkDebug.addExpectedMessage(debugMessage)
        testSinkError.addExpectedMessage(debugMessage)
        grandChildLogger.d().message(debugMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        testSinkDebug.addExpectedMessage(errorMessage)
        testSinkError.addExpectedMessage(errorMessage)
        grandChildLogger.e().message(errorMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        // remove filter override
        Core.get()
            .setFilter("test_sink_error", "childLogger", null)

        // validate it removed
        testSinkDebug.addExpectedMessage(debugMessage)
        childLogger.d().message(debugMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        testSinkDebug.addExpectedMessage(errorMessage)
        testSinkError.addExpectedMessage(errorMessage)
        childLogger.e().message(errorMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        // same for grandchild
        testSinkDebug.addExpectedMessage(debugMessage)
        grandChildLogger.d().message(debugMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        testSinkDebug.addExpectedMessage(errorMessage)
        testSinkError.addExpectedMessage(errorMessage)
        grandChildLogger.e().message(errorMessage)
        assertTrue("debug sink does not expects any messages", testSinkDebug.isEmpty())
        assertTrue("error sink does not expects any messages", testSinkError.isEmpty())

        Core.get().reset()
    }

    @Test
    fun testSinksView(){
        // validate the mapper uses sinks HashMap keys view
        val hashMap = mutableMapOf<String, ISink>(
            "sink0" to TestSink("Error"),
            "sink1" to TestSink("Error")
        )
        val mapper = Mapper(hashMap)
        val mappingBefore = mapper.getMapping("", "", LogLevel.debug.level)
        assertEquals(mappingBefore.size, 2)
        hashMap.remove("sink0")
        val mappingAfter = mapper.getMapping("", "", LogLevel.debug.level)
        assertEquals(mappingAfter.size, 1)
    }

    @Test
    fun testSinksSetViewIntegration() {
        // same as above, but through Core (some cases can not be tested via core with 100% reliability)
        val testSink0 = TestSink("Error")
        val testSink1 = TestSink("Error")

        val testEvent = Event(
            "tag",
            "subsystem",
            0L,
            LogLevel.debug.level,
            "message",
            null,
            null,
            null
        )

        // add mapping to not yet registered sinks
        Core.get().setFilter("test_sink_0", "subsystem") { _, _, _ -> true }
        Core.get().setFilter("test_sink_1", "subsystem") { _, _, _ -> true }

        var mapping = Core.get().getMapping(testEvent)
        assertTrue("No sinks available", mapping.isEmpty())

        // add sinks
        Core.get().addSink("test_sink_0", testSink0)
        Core.get().addSink("test_sink_1", testSink1)

        mapping = Core.get().getMapping(testEvent)
        // validate mapping to contain both sinks
        assertTrue("Sink0 was added", mapping.contains(testSink0))
        assertTrue("Sink1 was added", mapping.contains(testSink1))

        Core.get().removeSink(testSink1)
        // validate mapping to contain only one sink
        mapping = Core.get().getMapping(testEvent)
        assertTrue("Sink0 is still available", mapping.contains(testSink0))
        assertFalse("Sink1 was removed", mapping.contains(testSink1))

        Core.get().reset()
    }
}
