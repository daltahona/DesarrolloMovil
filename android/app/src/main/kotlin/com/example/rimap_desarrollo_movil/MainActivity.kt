package com.example.rimap_desarrollo_movil

import android.content.ContentValues
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Environment // 📌 Necesario para versiones antiguas
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File // 📌 Necesario para versiones antiguas
// import android.os.Bundle // No necesario en la clase si no se usa

class MainActivity : FlutterActivity() {

    // Canal idéntico al de Dart
    private val CHANNEL = "com.rimap_desarrollo_movil/save_image"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {
                    "saveImage" -> {
                        val imageBytes = call.argument<ByteArray>("image")
                        val name = call.argument<String>("name")

                        if (imageBytes == null || name == null) {
                            result.error(
                                "INVALID_ARGUMENTS",
                                "Faltan datos de imagen o nombre",
                                null
                            )
                            return@setMethodCallHandler
                        }
                        
                        // Envolver la lógica en try-catch para capturar excepciones
                        try {
                            val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)

                            val contentValues = ContentValues().apply {
                                put(MediaStore.Images.Media.DISPLAY_NAME, name)
                                put(MediaStore.Images.Media.MIME_TYPE, "image/png")
                                put(MediaStore.Images.Media.DATE_ADDED, System.currentTimeMillis() / 1000)
                                put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis())

                                // 📌 LÓGICA CLAVE: Manejo de versiones de Android (Scoped Storage)
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                                    // Android 10 (Q) y superior: Usa MediaStore con RELATIVE_PATH
                                    put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/ReportesRiohacha")
                                } else {
                                    // Android 9 (P) e inferior: Usa DATA y requiere permisos explícitos
                                    @Suppress("DEPRECATION")
                                    val directory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                                    val appDir = File(directory, "ReportesRiohacha")
                                    if (!appDir.exists()) {
                                        appDir.mkdirs()
                                    }
                                    val imageFile = File(appDir, name)
                                    @Suppress("DEPRECATION")
                                    put(MediaStore.Images.Media.DATA, imageFile.absolutePath)
                                }
                            }

                            val resolver = contentResolver
                            val uri = resolver.insert(
                                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                                contentValues
                            )

                            if (uri == null) {
                                result.error("SAVE_FAILED", "No se pudo crear URI para almacenar la imagen", null)
                                return@setMethodCallHandler
                            }

                            // Intentar escribir los bytes en el OutputStream del URI
                            val outputStream = resolver.openOutputStream(uri)

                            if (outputStream == null) {
                                result.error("STREAM_ERROR", "No se pudo abrir OutputStream", null)
                                return@setMethodCallHandler
                            }

                            // Usar use para asegurar que el stream se cierra
                            outputStream.use { stream ->
                                val success = bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)

                                if (success) {
                                    result.success(true)
                                } else {
                                    result.error("COMPRESS_FAILED", "Error comprimiendo el bitmap", null)
                                }
                            }
                            
                        } catch (e: Exception) {
                            result.error("EXCEPTION", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}