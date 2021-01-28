package com.applicaster.xray.ui.fragments

import android.content.Context
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.fragment.app.Fragment
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.Event
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.ui.R
import com.applicaster.xray.ui.adapters.EventRecyclerViewAdapter
import com.applicaster.xray.ui.sinks.InMemoryLogSink
import com.applicaster.xray.ui.utility.FilteredEventList

/**
 * A fragment representing a list of Items.
 */
class EventLogFragment : Fragment() {

    private var inMemorySinkName: String? = null
    private var defaultLevel: Int = LogLevel.info.level

    class SearchState(private var list: LiveData<List<Event>>,
                      lifecycleOwner: LifecycleOwner) : Observer<List<Event>> {

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
            if(result.isEmpty())
                return null
            val c = result.getOrNull(current) ?: return null
            return when(val idx = list.value!!.indexOf(c)) {
                -1 -> null
                else -> idx
            }
        }

        fun next(): Boolean {
            if(current + 1 < result.size ) {
                ++current
                return true
            }
            return false
        }

        fun prev(): Boolean {
            if (current > 0) {
                --current
                return true
            }
            return false
        }

        override fun onChanged(t: List<Event>?) {
            search()
        }

        private fun search() {
            if(text.isEmpty()) {
                result = emptyList()
                current = 0
                return
            }
            val c = result.getOrNull(current)
            result = list.value!!.filter { it.message.contains(text, ignoreCase = true) }.toList()
            current = result.indexOf(c).coerceAtLeast(0)
        }
    }

    private lateinit var searchState: SearchState

    override fun onInflate(context: Context, attrs: AttributeSet, savedInstanceState: Bundle?) {
        super.onInflate(context, attrs, savedInstanceState)
        val ta = context.obtainStyledAttributes(attrs, R.styleable.EventLogFragment_MembersInjector)
        if (ta.hasValue(R.styleable.EventLogFragment_MembersInjector_sink_name)) {
            inMemorySinkName = ta.getString(R.styleable.EventLogFragment_MembersInjector_sink_name)
        }
        if(ta.hasValue(R.styleable.EventLogFragment_MembersInjector_default_level)){
            ta.getString(R.styleable.EventLogFragment_MembersInjector_default_level)?.toIntOrNull()?.let {
                defaultLevel = LogLevel.fromLevel(it).level
            }
        }
        ta.recycle()
    }

    override fun onCreateView(
            inflater: LayoutInflater, container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(R.layout.xray_fragment_event_log_list, container, false)

        arguments?.let {
            // override value from xml
            inMemorySinkName = it.getString(ARG_SINK_NAME, inMemorySinkName)
        }

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
            searchState = SearchState(filteredList, viewLifecycleOwner)

            // Setup log level filter spinner
            view.findViewById<Spinner>(R.id.cb_filter).apply {
                adapter = ArrayAdapter(
                        context,
                        android.R.layout.simple_list_item_1,
                        LogLevel.values()
                )
                setSelection(defaultLevel)
                onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                    override fun onNothingSelected(parent: AdapterView<*>?) {
                    }

                    override fun onItemSelected(
                            parent: AdapterView<*>?,
                            view: View?,
                            position: Int,
                            id: Long
                    ) {
                        filteredList.level = LogLevel.values()[position]
                    }
                }
            }

            // Setup the list adapter
            val list = view.findViewById<RecyclerView>(R.id.list)
            list.apply {
                adapter = EventRecyclerViewAdapter(
                        viewLifecycleOwner,
                        filteredList,
                        searchState)
            }

            val filter = view.findViewById<LinearLayout>(R.id.cnt_filter)
            val bntFilter = view.findViewById<ToggleButton>(R.id.tb_filter)
            bntFilter.setOnCheckedChangeListener { _, isChecked ->
                    filter.visibility = if (isChecked) View.VISIBLE else View.GONE
                }

            val edSubsystem = filter.findViewById<EditText>(R.id.ed_subsystem)
            edSubsystem.addTextChangedListener(object :
                    TextWatcher {
                override fun beforeTextChanged(
                        s: CharSequence?,
                        start: Int,
                        count: Int,
                        after: Int
                ) = Unit

                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) =
                        Unit

                override fun afterTextChanged(s: Editable?) {
                    filteredList.subsystem = s.toString()
                }
            })

            val edCategory = filter.findViewById<EditText>(R.id.ed_category)
            edCategory.addTextChangedListener(object :
                    TextWatcher {
                override fun beforeTextChanged(
                        s: CharSequence?,
                        start: Int,
                        count: Int,
                        after: Int
                ) = Unit

                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) =
                        Unit

                override fun afterTextChanged(s: Editable?) {
                    filteredList.category = s.toString()
                }
            })

            // Search

            val search = view.findViewById<LinearLayout>(R.id.cnt_search)
            val bntSearch = view.findViewById<ToggleButton>(R.id.tb_search)
            bntSearch.setOnCheckedChangeListener { _, isChecked ->
                search.visibility = if (isChecked) View.VISIBLE else View.GONE
            }

            view.findViewById<EditText>(R.id.ed_text).addTextChangedListener(object :
                TextWatcher {
                override fun beforeTextChanged(
                    s: CharSequence?,
                    start: Int,
                    count: Int,
                    after: Int
                ) = Unit

                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) =
                    Unit

                override fun afterTextChanged(s: Editable?) {
                    searchState.update(s.toString())
                    list.adapter?.notifyDataSetChanged()
                    searchState.getCurrentIndex()?.let {
                        list.scrollToPosition(it)
                    }
                }
            })

            view.findViewById<View>(R.id.btn_prev).setOnClickListener {
                if (searchState.prev()) {
                    list.adapter?.notifyDataSetChanged()
                    searchState.getCurrentIndex()?.let {
                        list.scrollToPosition(it)
                    }
                }
            }
            view.findViewById<View>(R.id.btn_next).setOnClickListener {
                if (searchState.next()) {
                    list.adapter?.notifyDataSetChanged()
                    searchState.getCurrentIndex()?.let {
                        list.scrollToPosition(it)
                    }
                }
            }
        }

        view.setTag(R.id.fragment_title_tag, getString(R.string.tab_title_events))
        return view
    }

    companion object {
        @JvmStatic
        fun newInstance() = EventLogFragment()

        @JvmStatic
        fun newInstance(sinkName: String) = EventLogFragment().apply {
            arguments = Bundle().apply {
                putString(ARG_SINK_NAME, sinkName)
            }
        }

        private const val ARG_SINK_NAME: String = "sink_name"
    }
}