package com.applicaster.xray.ui.adapters

import android.content.ClipData
import android.content.ClipboardManager
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.format.DateFormat
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import android.widget.Toast
import androidx.core.content.ContextCompat.getSystemService
import androidx.core.text.bold
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.xray.core.Event
import com.applicaster.xray.ui.R
import com.applicaster.xray.ui.fragments.model.SearchState
import com.applicaster.xray.ui.utility.format
import com.google.gson.GsonBuilder
import kotlinx.android.synthetic.main.xray_fragment_event_log_entry.view.*
import java.util.*


class EventRecyclerViewAdapter(
    owner: LifecycleOwner,
    observableEventList: LiveData<List<Event>>,
    private val searchState: SearchState
) : RecyclerView.Adapter<EventRecyclerViewAdapter.ViewHolder>(), Observer<List<Event>> {

    private var values: List<Event> = observableEventList.value!!

    private var gson = GsonBuilder().setPrettyPrinting().create()

    // No IdentityHashSet available and we can't provide custom compare function in set in Java
    // Comparing the entire Event is not needed, and we can't use indexes
    private var expanded = IdentityHashMap<Event, Event>()

    init {
        observableEventList.observe(owner, this)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = LayoutInflater.from(parent.context)
            .inflate(R.layout.xray_fragment_event_log_entry, parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = values[position]
        holder.bind(item)
    }

    override fun getItemCount(): Int = values.size

    inner class ViewHolder(private val view: View) : RecyclerView.ViewHolder(view) {

        // cache synthetics
        private val time: TextView = view.time
        private val message: TextView = view.message
        private val details: TextView = view.lbl_details
        private val subsystem: TextView = view.lbl_subsystem
        private val category: TextView = view.lbl_category
        private val colorTag: View = view.view_color_tag

        private var event: Event? = null

        // should be static, but its internal class
        private val colors = view.resources.getIntArray(R.array.log_levels)
        private val detailsHint = view.context.getString(R.string.xray_lbl_tap_for_details)
        private val searchColorCurrent = view.resources.getColor(android.R.color.holo_blue_bright)
        private val searchColorIsIn = view.resources.getColor(android.R.color.holo_blue_dark)
        private val searchColorDefault = view.resources.getColor(android.R.color.transparent)

        init {
            // on long click copy to clipboard
            view.setOnLongClickListener {
                getSystemService(
                    view.context,
                    ClipboardManager::class.java
                )?.let {
                    val clip = ClipData.newPlainText("log event", event!!.format())
                    it.setPrimaryClip(clip)
                    Toast.makeText(
                        view.context,
                        "Message was copied to clipboard",
                        Toast.LENGTH_SHORT
                    ).show()
                }
                true
            }
            // on short click show details if any
            view.setOnClickListener {
                if (detailsHint == details.text && hasDetails(event!!)) {
                    details.text = formatDetails(event!!)
                    expanded[event] = event
                } else {
                    details.text = detailsHint
                    expanded.remove(event)
                }
            }
        }

        override fun toString(): String = super.toString() + " '" + view.message.text + "'"

        fun bind(item: Event) {
            event = item
            time.text = DateFormat.format("yyyy-MM-dd HH:mm:ss", item.timestamp)
            message.text = item.message
            category.text = item.category
            subsystem.text = item.subsystem
            colorTag.setBackgroundColor(getColor(item))
            if(hasDetails(item)) {
                details.text = if(expanded.contains(item)) formatDetails(item) else detailsHint
                details.visibility = View.VISIBLE
            } else {
                details.visibility = View.GONE
            }
            view.setBackgroundColor(
                when {
                    searchState.isCurrent(item) -> searchColorCurrent
                    searchState.isIn(item) -> searchColorIsIn
                    else -> searchColorDefault
                }
            )
        }

        private fun hasDetails(item: Event) =
            !item.data.isNullOrEmpty() || !item.context.isNullOrEmpty() || null != item.exception

        private fun getColor(item: Event) =
            if (item.level < colors.size) colors[item.level] else colors.last()

        private fun formatDetails(event: Event): Spannable = SpannableStringBuilder().apply {
            if (true == event.data?.isNotEmpty()) {
                bold { append("Data:\n") }
                append(gson.toJson(event.data))
            }
            event.exception?.let { exception ->
                if (isNotEmpty()) {
                    append('\n')
                }
                bold { append("Exception:\n") }
                exception.message?.let { message ->
                    append(message)
                    append("\n")
                }
                append(Log.getStackTraceString(exception))
            }
            if (true == event.context?.isNotEmpty()) {
                if (isNotEmpty()) {
                    append('\n')
                }
                bold { append("Context:\n") }
                append(gson.toJson(event.context))
            }
        }

    }

    override fun onChanged(t: List<Event>?) {
        this.values = t!!
        notifyDataSetChanged()
    }
}

