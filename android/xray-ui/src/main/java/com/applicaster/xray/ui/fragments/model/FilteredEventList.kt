package com.applicaster.xray.ui.fragments.model

import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.Observer
import com.applicaster.xray.core.Event
import com.applicaster.xray.core.LogLevel

class FilteredEventList(
    owner: LifecycleOwner,
    private val originalList: LiveData<List<Event>>
) : MutableLiveData<List<Event>>(), Observer<List<Event>> {

    private class Filter {
        var subsystem: String = ""
        var category: String = ""
        var level: LogLevel = LogLevel.verbose
        fun filter(event: Event): Boolean = event.level >= level.level
                && (subsystem.isBlank() or event.subsystem.contains(subsystem, true))
                && (category.isBlank() or event.category.contains(category, true))
    }

    private val filter = Filter()

    var subsystem: String
        set(value) {
            filter.subsystem = value
            update()
        }
        get() = filter.subsystem

    var category: String
        set(value) {
            filter.category = value
            update()
        }
        get() = filter.category

    var level: LogLevel
        set(value) {
            filter.level = value
            update()
        }
        get() = filter.level

    private fun update() {
        // Assuming we are in the main thread
        value = originalList.value!!.filter { filter.filter(it) }
    }

    init {
        update()
        this.originalList.observe(owner, this)
    }

    override fun onChanged(t: List<Event>?) = update()
}
