package com.chotanews

import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.core.content.FileProvider
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.chotanews/whatsapp"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareToWhatsApp") {
                val imagePath = call.argument<String>("imagePath")
                val text = call.argument<String>("text")
                shareToWhatsApp(imagePath, text, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun shareToWhatsApp(imagePath: String?, text: String?, result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_SEND)
        if (imagePath != null && imagePath.endsWith(".pdf", ignoreCase = true)) {
            intent.type = "application/pdf"
        } else {
            intent.type = "image/*"
        }
        intent.setPackage("com.whatsapp")
        
        if (text != null) {
            intent.putExtra(Intent.EXTRA_TEXT, text)
        }
        
        if (imagePath != null) {
            val file = File(imagePath)
            // Using standard share_plus file provider or custom one. Since share_plus is in pubspec, it declares dev.fluttercommunity.plus.share.Provider
            // Actually, a safer fallback is just letting the system figure out the URI using the standard provider, or providing our own.
            // But since Flutter 3+, often you need to declare a provider. Let's use the standard one you'd usually declare, or the one from share_plus.
            // A more robust way in Flutter Android is passing the file path and using the FileProvider from share_plus.
            // The authority for share_plus is "\${applicationId}.flutter.share_provider"
            try {
                // The authority declared in AndroidManifest.xml is "\${applicationId}.fileprovider"
                val uri = FileProvider.getUriForFile(this, "${applicationContext.packageName}.fileprovider", file)
                intent.putExtra(Intent.EXTRA_STREAM, uri)
                intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            } catch (e: Exception) {
                result.error("PROVIDER_ERROR", "Could not get Uri for file. Did you add the FileProvider to AndroidManifest?", e.message)
                return
            }
        }
        
        try {
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("APP_NOT_INSTALLED", "WhatsApp is not installed", null)
        }
    }
}