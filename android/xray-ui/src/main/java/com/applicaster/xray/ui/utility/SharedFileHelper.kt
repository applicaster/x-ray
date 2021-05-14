package com.applicaster.xray.ui.utility

import android.content.ContentValues
import android.content.Context
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.annotation.RequiresApi
import java.io.File
import java.io.IOException
import java.nio.charset.StandardCharsets

object SharedFileHelper {

    fun copyToDownloads(
        context: Context,
        file: File,
        target: String,
        mime: String
    ): String? {
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> saveAndroidQ(
                context,
                file.readText(),
                target,
                mime
            )
            else -> file.copyTo(File(context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), target)).toString()
        }
    }

    /**
     * Try to save given string as a file to user Downloads folder.
     * Does not guarantee to return real path for Android 10+
     */
    fun saveToDownloads(
        context: Context,
        text: String,
        name: String,
        mime: String
    ): String? {
        return when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q -> saveAndroidQ(
                context,
                text,
                name,
                mime
            )
            else -> saveLegacy(context, name, text)
        }
    }

    private fun saveLegacy(
        context: Context,
        name: String,
        text: String
    ): String {
        return File(
            context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), name
        ).apply {
            writeText(text)
        }.toString()
    }

    @RequiresApi(api = Build.VERSION_CODES.Q)
    private fun saveAndroidQ(
        context: Context,
        text: String,
        name: String,
        mime: String
    ): String? {
        val contentValues = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, name)
            put(MediaStore.Downloads.MIME_TYPE, mime)
            put(MediaStore.Downloads.IS_PENDING, true)
        }
        val contentResolver = context.contentResolver
        val uri = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL)
        val itemUri = contentResolver.insert(uri, contentValues)
            ?: throw IOException("Failed to access storage")
        contentResolver.openOutputStream(itemUri).use { outputStream ->
            outputStream!!.write(text.toByteArray(StandardCharsets.UTF_8))
            contentValues.put(MediaStore.Images.Media.IS_PENDING, false)
            contentResolver.update(itemUri, contentValues, null, null)
        }
        // return some fake name to give user some idea where file is located
        return itemUri.toString().replaceAfterLast("/", name)
    }
}
