package com.applicaster.xray.ui.fragments

import android.content.Context
import android.content.DialogInterface
import android.os.Bundle
import android.util.AttributeSet
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.appcompat.app.AlertDialog
import androidx.core.widget.doAfterTextChanged
import androidx.fragment.app.Fragment
import androidx.lifecycle.LiveData
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.xray.core.Core
import com.applicaster.xray.core.Event
import com.applicaster.xray.core.LogLevel
import com.applicaster.xray.crashreporter.Reporting
import com.applicaster.xray.ui.R
import com.applicaster.xray.ui.adapters.EventRecyclerViewAdapter
import com.applicaster.xray.ui.fragments.model.FilteredEventList
import com.applicaster.xray.ui.fragments.model.SearchState
import com.applicaster.xray.ui.sinks.InMemoryLogSink
import com.applicaster.xray.ui.utility.GsonHolder
import com.applicaster.xray.ui.utility.SharedFileHelper
import java.util.*
import java.util.concurrent.atomic.AtomicInteger

/**
 * A fragment representing a list of Items.
 */
class EventLogFragment : Fragment() {

    private var inMemorySinkName: String? = null
    private var defaultLevel: Int = LogLevel.info.level

    private lateinit var searchState: SearchState // can be local, but member for debugging

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
        val inMemoryLogSink = inMemorySinkName?.let {
            Core.get().getSink(it) as? InMemoryLogSink?
        }

        // todo: show message if sink is missing
        if (null != inMemoryLogSink) {

            // Wrap original list to filtered one
            val filteredList = FilteredEventList(viewLifecycleOwner, inMemoryLogSink.getLiveData())
            // Here I rely on the fact that the EventRecyclerViewAdapter below will be notified after SearchState.
            // Its not very good, since its not guaranteed, I just know that these observers are stored as a linked list internally.
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
            edSubsystem.doAfterTextChanged {
                filteredList.subsystem = it.toString()
            }

            val edCategory = filter.findViewById<EditText>(R.id.ed_category)
            edCategory.doAfterTextChanged {
                filteredList.category = it.toString()
            }

            // Search

            val search = view.findViewById<LinearLayout>(R.id.cnt_search)
            view.findViewById<ToggleButton>(R.id.tb_search).setOnCheckedChangeListener { _, isChecked ->
                search.visibility = if (isChecked) View.VISIBLE else View.GONE
            }

            fun onSearchUpdated() {
                list.adapter?.notifyDataSetChanged()
                searchState.getCurrentIndex()?.let {
                    list.scrollToPosition(it)
                }
            }

            view.findViewById<EditText>(R.id.ed_text).doAfterTextChanged {
                searchState.update(it.toString())
                onSearchUpdated()
            }

            view.findViewById<View>(R.id.btn_prev).setOnClickListener {
                if (searchState.prev())
                    onSearchUpdated()
            }

            view.findViewById<View>(R.id.btn_next).setOnClickListener {
                if (searchState.next())
                    onSearchUpdated()
            }

            view.findViewById<View>(R.id.btn_search_filter).setOnClickListener {
                val mask = searchState.getMask()
                val checkedItems = resources
                    .getStringArray(R.array.xray_search_masks)
                    .mapIndexed { i, _ -> mask and (1 shl i) != 0 }
                    .toBooleanArray()

                val l = object
                    : DialogInterface.OnMultiChoiceClickListener
                    , DialogInterface.OnClickListener {

                    private var newMask = mask

                    override fun onClick(dialog: DialogInterface?, which: Int, isChecked: Boolean) {
                        val bit = 1 shl which
                        newMask = if (isChecked) newMask.or(bit) else newMask.xor(bit)
                    }

                    override fun onClick(dialog: DialogInterface?, which: Int) {
                        searchState.setMask(newMask)
                        onSearchUpdated()
                    }
                }

                AlertDialog.Builder(view.context)
                    .setMultiChoiceItems(R.array.xray_search_masks, checkedItems, l)
                    .setPositiveButton(android.R.string.ok, l)
                    .setNegativeButton(android.R.string.cancel, null)
                    .show()
            }

            view.findViewById<View>(R.id.btn_share).setOnClickListener {
                share(view.context, inMemoryLogSink.getLiveData(), filteredList)
            }
        }

        view.setTag(R.id.fragment_title_tag, getString(R.string.tab_title_events))
        return view
    }

    private fun share(
        context: Context,
        unfilteredList: LiveData<List<Event>>,
        filteredList: LiveData<List<Event>>
    ) {
        // AtomicInteger is used just to keep the integer value as a reference
        val shareType = AtomicInteger(0)

        val shareListener = DialogInterface.OnClickListener { _, which ->
            val events = when {
                0 == shareType.get() -> filteredList.value!!
                else -> unfilteredList.value!!
            }
            if(AlertDialog.BUTTON_POSITIVE == which)
                shareEvents(context, events, ShareTarget.file)
            else
                shareEvents(context, events, ShareTarget.intent)
        }

        // uses neutral button for cancel since its visually outstanding one
        AlertDialog.Builder(context)
            .setTitle(getString(R.string.xray_dlg_title_share_events))
            .setPositiveButton(R.string.xray_btn_share_target_file, shareListener)
            .setNegativeButton(R.string.xray_btn_share_target_intent, shareListener)
            .setNeutralButton(android.R.string.cancel, null)
            .setSingleChoiceItems(
                R.array.xray_share_events_type, 0
            ) { _, which -> shareType.set(which) }
            .show()
    }

    private enum class ShareTarget {
        file,
        intent
    }

    private fun shareEvents(
        ctx: Context,
        events: List<Event>,
        target: ShareTarget
    ) {
        if(events.isEmpty()) {
            Toast.makeText(context, "No events to share", Toast.LENGTH_LONG).show()
            return
        }
        try {
            val json = GsonHolder.gson.toJson(events)
            if (ShareTarget.intent == target) {
                ctx.openFileOutput("events.json", 0).use { it.write(json.toByteArray()) }
                Reporting.sendLogReport(activity!!, ctx.getFileStreamPath("events.json"))
            } else {
                val file = SharedFileHelper.saveToDownloads(
                    ctx,
                    json,
                    "events_${Date().time}.json",
                    "application/json"
                )
                Toast.makeText(context, "Log was saved to $file", Toast.LENGTH_LONG).show()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error during export", e)
            Toast.makeText(context, "Error during export ${e.message}", Toast.LENGTH_LONG)
                .show()
        }
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
        private const val TAG: String = "EventLogFragment"
    }
}