package com.applicaster.xray

import com.applicaster.xray.core.Core
import com.applicaster.xray.core.Logger
import org.junit.Assert.assertSame
import org.junit.Test

/**
 * Testing for logger hierarchical creation
 */
class LoggerHierarchyUnitTest {

    @Test
    fun testLoggerHierarchy() {
        val grandGrandChild = Logger.get().getChild("childLogger/grandChildLogger/grandGrandChildLogger")
        val childLogger = Logger.get().getChild("childLogger")
        val grandChildLogger = childLogger.getChild("grandChildLogger")
        val grandGrandChildLogger = grandChildLogger.getChild("grandGrandChildLogger")
        assertSame(grandGrandChildLogger, grandGrandChild)
        Core.get().reset()
    }

}
