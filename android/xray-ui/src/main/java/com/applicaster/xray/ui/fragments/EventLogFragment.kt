package com.applicaster.xray.ui.fragments

import android.content.Context
import android.os.Bundle
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.Spinner
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.plugin.xray.R
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.ui.adapters.EventRecyclerViewAdapter
import com.applicaster.xray.ui.sinks.InMemoryLogSink
import com.applicaster.xray.ui.utility.FilteredEventList

/**
 * A fragment representing a list of Items.
 */
class EventLogFragment : Fragment() {

    private var inMemorySinkName: String? = null

    override fun onInflate(context: Context, attrs: AttributeSet, savedInstanceState: Bundle?) {
        super.onInflate(context, attrs, savedInstanceState)
        val ta = context.obtainStyledAttributes(attrs, R.styleable.EventLogFragment_MembersInjector)
        if (ta.hasValue(R.styleable.EventLogFragment_MembersInjector_sink_name)) {
            inMemorySinkName = ta.getString(R.styleable.EventLogFragment_MembersInjector_sink_name)
        }
        ta.recycle()
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(R.layout.xray_fragment_event_log_list, container, false)

        // We expect our example Plugin to provide this sink as InMemoryLogSink
        val inMemoryLogSink =
            when (inMemorySinkName) {
                null -> null
                else -> Core.get().getSink(inMemorySinkName!!) as InMemoryLogSink?
            }

        // todo: show message if sink is missing
        if (null != inMemoryLogSink) {

            // Wrap original list to filtered one
            val filteredList = FilteredEventList(viewLifecycleOwner, inMemoryLogSink.getLiveData())

            // Setup log level filter spinner
            view.findViewById<Spinner>(R.id.cb_filter).apply {
                adapter = ArrayAdapter(
                    context,
                    android.R.layout.simple_list_item_1,
                    LogLevel.values()
                )
                setSelection(LogLevel.info.level)
                onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                    override fun onNothingSelected(parent: AdapterView<*>?) {
                    }

                    override fun onItemSelected(
                        parent: AdapterView<*>?,
                        view: View?,
                        position: Int,
                        id: Long
                    ) {
                        filteredList.filter = LogLevel.values()[position]
                    }
                }
            }

            // Setup the list adapter
            view.findViewById<RecyclerView>(R.id.list).apply {
                adapter = EventRecyclerViewAdapter(
                    viewLifecycleOwner,
                    filteredList
                )
            }

        }
        view.setTag(R.id.fragment_title_tag, getString(R.string.tab_title_events))
        return view
    }

    companion object {

        @JvmStatic
        fun newInstance() = EventLogFragment()
    }
}