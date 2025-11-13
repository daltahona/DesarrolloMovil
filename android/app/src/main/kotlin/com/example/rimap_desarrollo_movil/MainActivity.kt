package com.example.rimap_desarrollo_movil

import android.content.ContentValues
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Bundle
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.rimap_desarrollo_movil/save_image"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "saveImage") {
                    val imageBytes = call.argument<ByteArray>("image")
                    val name = call.argument<String>("name")

                    if (imageBytes == null || name == null) {
                        result.error("INVALID_ARGUMENTS", "Faltan datos de imagen o nombre", null)
                        return@setMethodCallHandler
                    }

                    val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

                    val contentValues = ContentValues().apply {
                        put(MediaStore.Images.Media.DISPLAY_NAME, name)
                        put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                        put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/CapturasMapa")
                    }

                    val uri = contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                    val outputStream = uri?.let { contentResolver.openOutputStream(it) }

                    outputStream?.let {
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, it)
                        it.close()
                        result.success(true)
                    } ?: result.error("SAVE_FAILED", "No se pudo abrir el OutputStream", null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
