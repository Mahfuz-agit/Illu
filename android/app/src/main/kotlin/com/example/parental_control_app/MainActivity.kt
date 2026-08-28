package com.example.parental_control_app

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val ADMIN_CHANNEL = "com.example.parental_control_app/device_admin"
    private val ACCESSIBILITY_CHANNEL = "com.example.parental_control_app/accessibility"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Handle Screen Lock (Device Admin)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ADMIN_CHANNEL).setMethodCallHandler { call, result ->
            val devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val compName = ComponentName(this, AdminReceiver::class.java)

            when (call.method) {
                "requestAdmin" -> {
                    val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
                    intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, compName)
                    intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION, "Required to remotely lock device")
                    startActivity(intent)
                    result.success(true)
                }
                "lockScreen" -> {
                    if (devicePolicyManager.isAdminActive(compName)) {
                        devicePolicyManager.lockNow()
                        result.success(true)
                    } else {
                        result.error("NOT_ADMIN", "Device Admin not enabled", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // Handle App Blocking (Accessibility)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ACCESSIBILITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkAccessibility" -> result.success(true)
                "requestAccessibility" -> {
                    startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                    result.success(true)
                }
                "blockApp" -> {
                    call.argument<String>("package")?.let { AppBlockerAccessibilityService.blockedApps.add(it) }
                    result.success(true)
                }
                "unblockApp" -> {
                    call.argument<String>("package")?.let { AppBlockerAccessibilityService.blockedApps.remove(it) }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
