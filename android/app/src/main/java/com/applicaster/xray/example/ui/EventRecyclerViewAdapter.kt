package com.applicaster.xray.example.ui

import android.content.ClipData
import android.content.ClipboardManager
import android.text.format.DateFormat
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.Toast
import androidx.core.content.ContextCompat.getSystemService
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LiveData
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.RecyclerView
import com.applicaster.xray.core.Event
import com.applicaster.xray.example.R
import com.applicaster.xray.example.databinding.FragmentEventLogBinding
import com.applicaster.xray.example.utility.format

class EventRecyclerViewAdapter(
    owner: LifecycleOwner,
    observableEventList: LiveData<List<Event>>
) : RecyclerView.Adapter<EventRecyclerViewAdapter.ViewHolder>(), Observer<List<Event>> {

    private var values: List<Event> = observableEventList.value!!
    init {
        observableEventList.observe(owner, this)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = FragmentEventLogBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = values[position]
        holder.bind(item)
    }

    override fun getItemCount(): Int = values.size

    inner class ViewHolder(private val binding: FragmentEventLogBinding)
        : RecyclerView.ViewHolder(binding.root) {

        init {
            binding.root.setOnLongClickListener {
                getSystemService<ClipboardManager>(
                    binding.root.context,
                    ClipboardManager::class.java
                )?.let {
                    val clip = ClipData.newPlainText("log event", event!!.format())
                    it.setPrimaryClip(clip)
                    Toast.makeText(
                        binding.root.context,
                        "Message was copied to clipboard",
                        Toast.LENGTH_SHORT
                    ).show()
                }
                true
            }
        }

        private var event: Event? = null

        // should be static, but its internal class
        private val colors = binding.viewColorTag.resources.getIntArray(R.array.log_levels)

        override fun toString(): String {
            return super.toString() + " '" + binding.message.text + "'"
        }

        fun bind(item: Event) {
            event = item
            binding.tag.text = "${item.category} ${item.subsystem}"
            binding.message.text = item.message
            binding.time.text = DateFormat.format("yyyy-MM-dd HH:mm:ss", item.timestamp)
            binding.viewColorTag.setBackgroundColor(getColor(item))
        }

        private fun getColor(item: Event): Int {
            return if (item.level < colors.size) colors[item.level] else colors.last()
        }
    }

    override fun onChanged(t: List<Event>?) {
        this.values = t!!
        notifyDataSetChanged()
    }
}

