package com.toan.student_ecommerce

import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import java.security.MessageDigest

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        printHashKey()
    }

    private fun printHashKey() {
        try {
            val info = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNATURES
            )
            for (signature in info.signatures ?: arrayOf()) {
                val md = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                val hashKey = Base64.encodeToString(md.digest(), Base64.DEFAULT)
                Log.d("Facebook KeyHash", hashKey)
                println("🔑 Facebook Key Hash: $hashKey")
            }
        } catch (e: Exception) {
            Log.e("Facebook KeyHash", "Error: ${e.message}")
        }
    }
}
