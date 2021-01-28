package com.applicaster.xray.ui.fragments.model

import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import com.applicaster.xray.core.Event

class SearchState(private var list: LiveData<List<Event>>,
                  lifecycleOwner: LifecycleOwner
) : Observer<List<Event>> {

    init {
        list.observe(lifecycleOwner, this)
    }

    fun update(text: String) {
        this.text = text
        search()
    }

    private var text = ""
    private var result: List<Event> = emptyList()
    private var current: Int = 0

    fun isIn(event: Event): Boolean = result.contains(event)

    fun isCurrent(event: Event): Boolean {
        return result.isNotEmpty() && current < result.size && result[current] == event
    }

    fun getCurrentIndex(): Int? {
        val c = result.getOrNull(current) ?: return null
        return when(val idx = list.value!!.indexOf(c)) {
            -1 -> null
            else -> idx
        }
    }

    fun next(): Boolean {
        return when {
            current + 1 >= result.size -> false
            else -> {
                ++current
                true
            }
        }
    }

    fun prev(): Boolean {
        return when {
            current <= 0 -> false
            else -> {
                --current
                true
            }
        }
    }

    override fun onChanged(t: List<Event>?) = search()

    private fun search() {
        if(text.isEmpty()) {
            result = emptyList()
            current = 0 // can probably use -1
            return
        }
        val c = result.getOrNull(current)
        result = list.value!!.filter { it.message.contains(text, ignoreCase = true) }.toList()
        current = if(null != c) result.indexOf(c).coerceAtLeast(0) else 0
    }
}