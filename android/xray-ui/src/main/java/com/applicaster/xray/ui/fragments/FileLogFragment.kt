package com.applicaster.xray.ui.fragments

import android.content.Context
import android.os.Bundle
import android.os.FileObserver
import android.text.TextUtils
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.lifecycle.Lifecycle
import com.applicaster.plugin.xray.R
import com.applicaster.xray.crashreporter.Reporting
import java.io.File

class FileLogFragment : Fragment() {

    private var fileSinkFileName: String? = null
    private var file: File? = null
    private var observer: FileObserver? = null

    private var logView: TextView? = null
    private var btnClear: Button? = null
    private var btnSend: Button? = null

    private val updater: Runnable = Runnable { reloadLog() }
    private lateinit var fileCreateListener: Runnable

    init {
        fileCreateListener = Runnable {
            logView?.removeCallbacks(fileCreateListener)
            if(!lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
                return@Runnable
            }
            if(null == file) {
                logView?.postDelayed(fileCreateListener, 500)
                return@Runnable
            }
            if(file!!.exists()) {
                reloadLog()
            } else {
                logView?.postDelayed(fileCreateListener, 500)
            }
        }
    }

    override fun onInflate(context: Context, attrs: AttributeSet, savedInstanceState: Bundle?) {
        super.onInflate(context, attrs, savedInstanceState)
        val ta = context.obtainStyledAttributes(attrs, R.styleable.FileLogFragment_MembersInjector)
        if (ta.hasValue(R.styleable.FileLogFragment_MembersInjector_file_name)) {
            fileSinkFileName = ta.getString(R.styleable.FileLogFragment_MembersInjector_file_name)
        }
        ta.recycle()
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        val view = inflater.inflate(R.layout.xray_fragment_log, container, false)
        file = activity!!.getFileStreamPath(fileSinkFileName)
        logView = view.findViewById(R.id.lbl_log)
        btnSend = view.findViewById(R.id.btn_send)
        btnSend?.setOnClickListener { send() }
        btnClear = view.findViewById(R.id.btn_clear)
        btnClear?.setOnClickListener { clear() }
        view.setTag(R.id.fragment_title_tag, file!!.name)
        return view
    }

    private fun reloadLog() {
        if(!lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
            return
        }
        if (null == logView) {
            return
        }
        var hasLog = false
        if (!file!!.exists()) {
            logView?.text = MSG_NOT_FOUND
            logView?.postDelayed(fileCreateListener, 500)
        } else {
            val log = file!!.readText(Charsets.UTF_8)
            hasLog = !TextUtils.isEmpty(log)
            logView?.text = if (hasLog) log else MSG_EMPTY
            startFileObserver() // can be called multiple times, no problem
        }
        btnSend?.isEnabled = hasLog
        btnClear?.isEnabled = hasLog
    }

    private fun startFileObserver() {
        if (null != file) {
            @Suppress("DEPRECATION")
            observer = object : FileObserver(file?.absolutePath, CLOSE_WRITE or DELETE_SELF) {
                override fun onEvent(event: Int, path: String?) {
                    // do not let update too often, it degrade performance to a point of unusable
                    logView?.removeCallbacks(updater)
                    logView?.postDelayed(updater, UPDATE_DELAY)
                    if(event == DELETE_SELF) {
                        // file descriptor will be new, this observer will not work anymore
                        observer = null
                    }
                }
            }
            observer?.startWatching()
        }
    }

    override fun onPause() {
        super.onPause()
        observer?.stopWatching()
        logView?.removeCallbacks(updater)
        logView?.removeCallbacks(fileCreateListener)
    }

    override fun onResume() {
        super.onResume()
        logView?.post(updater)
    }

    private fun send() {
        if (file!!.exists()) {
            Reporting.sendLogReport(activity!!, file)
        }
    }

    private fun clear() {
        // it should trigger file observer, but for clarity we set it here, too
        if (file!!.delete()) {
            logView!!.text = MSG_NOT_FOUND
            btnSend?.isEnabled = false
            btnClear?.isEnabled = false
        }
    }

    companion object {
        @JvmStatic
        fun newInstance() = FileLogFragment()
        private const val UPDATE_DELAY = 100L
        private const val MSG_EMPTY = "[Empty]"
        private const val MSG_NOT_FOUND = "[Not found]"
    }
}