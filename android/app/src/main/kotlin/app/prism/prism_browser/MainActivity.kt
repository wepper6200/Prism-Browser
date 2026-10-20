package app.prism.prism_browser

import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.prism.browser/files")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "publishDownload" -> result.success(
                        publish(
                            call.argument<String>("path") ?: "",
                            call.argument<String>("name") ?: "download",
                            call.argument<String>("mime"),
                        )
                    )
                    "open" -> result.success(
                        open(
                            call.argument<String>("uri"),
                            call.argument<String>("path"),
                            call.argument<String>("mime"),
                        )
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun mimeOf(name: String, mime: String?): String {
        if (!mime.isNullOrBlank() && mime != "application/octet-stream") return mime
        val ext = name.substringAfterLast('.', "").lowercase()
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext)
            ?: "application/octet-stream"
    }

    /**
     * Android 10+: copies a finished download into the public Downloads
     * folder through MediaStore (no storage permission) and deletes the
     * app-private copy. Returns the content:// URI, or null when the file
     * stays in the app's own folder (older Android, or on failure).
     */
    private fun publish(path: String, name: String, mime: String?): String? {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return null
        val src = File(path)
        if (!src.isFile) return null
        val resolver = contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, name)
            put(MediaStore.Downloads.MIME_TYPE, mimeOf(name, mime))
            put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: return null
        return try {
            resolver.openOutputStream(uri)?.use { out ->
                src.inputStream().use { it.copyTo(out) }
            } ?: throw IllegalStateException("no output stream")
            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            src.delete()
            uri.toString()
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            null
        }
    }

    /** Opens a download with the default app for its type. */
    private fun open(uri: String?, path: String?, mime: String?): Boolean {
        val target: Uri = when {
            !uri.isNullOrBlank() -> Uri.parse(uri)
            !path.isNullOrBlank() && File(path).isFile ->
                FileProvider.getUriForFile(this, "$packageName.files", File(path))
            else -> return false
        }
        val name = path?.substringAfterLast('/') ?: ""
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(target, mimeOf(name, mime))
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return try {
            startActivity(Intent.createChooser(intent, null).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            true
        } catch (e: ActivityNotFoundException) {
            false
        }
    }
}
