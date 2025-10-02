package com.ahmtydn.contacts_bridge

import android.Manifest
import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds.*
import android.provider.ContactsContract.Data
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.*
import java.util.*

/** ContactsBridgePlugin */
class ContactsBridgePlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {

    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: android.app.Activity? = null
    private var resolver: ContentResolver? = null
    private var permissionResult: Result? = null
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    companion object {
        private const val PERMISSION_REQUEST_READ_CONTACTS = 1001
        private const val PERMISSION_REQUEST_WRITE_CONTACTS = 1002
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.ahmtydn.contacts_bridge")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        resolver = context?.contentResolver
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "requestPermission" -> {
                handleRequestPermission(call, result)
            }
            "getPermissionStatus" -> {
                handleGetPermissionStatus(result)
            }
            "getAllContacts" -> {
                handleGetAllContacts(call, result)
            }
            "getContact" -> {
                handleGetContact(call, result)
            }
            "searchContacts" -> {
                handleSearchContacts(call, result)
            }
            "createContact" -> {
                handleCreateContact(call, result)
            }
            "updateContact" -> {
                handleUpdateContact(call, result)
            }
            "deleteContact" -> {
                handleDeleteContact(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun handleRequestPermission(call: MethodCall, result: Result) {
        val args = call.arguments as? Map<String, Any>
        val readOnly = args?.get("readOnly") as? Boolean ?: false

        val readPermission = Manifest.permission.READ_CONTACTS
        val writePermission = Manifest.permission.WRITE_CONTACTS

        context?.let { ctx ->
            val hasReadPermission = ContextCompat.checkSelfPermission(ctx, readPermission) == PackageManager.PERMISSION_GRANTED
            val hasWritePermission = ContextCompat.checkSelfPermission(ctx, writePermission) == PackageManager.PERMISSION_GRANTED

            if (hasReadPermission && (readOnly || hasWritePermission)) {
                result.success("granted")
            } else {
                activity?.let { act ->
                    permissionResult = result
                    if (readOnly) {
                        ActivityCompat.requestPermissions(act, arrayOf(readPermission), PERMISSION_REQUEST_READ_CONTACTS)
                    } else {
                        ActivityCompat.requestPermissions(act, arrayOf(readPermission, writePermission), PERMISSION_REQUEST_WRITE_CONTACTS)
                    }
                } ?: result.error("NO_ACTIVITY", "Activity not available", null)
            }
        } ?: result.error("NO_CONTEXT", "Context not available", null)
    }

    private fun handleGetPermissionStatus(result: Result) {
        context?.let { ctx ->
            val readPermission = ContextCompat.checkSelfPermission(ctx, Manifest.permission.READ_CONTACTS)
            val writePermission = ContextCompat.checkSelfPermission(ctx, Manifest.permission.WRITE_CONTACTS)

            when {
                readPermission == PackageManager.PERMISSION_GRANTED && writePermission == PackageManager.PERMISSION_GRANTED -> {
                    result.success("granted")
                }
                readPermission == PackageManager.PERMISSION_GRANTED -> {
                    result.success("grantedReadOnly")
                }
                else -> {
                    result.success("denied")
                }
            }
        } ?: result.error("NO_CONTEXT", "Context not available", null)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        when (requestCode) {
            PERMISSION_REQUEST_READ_CONTACTS -> {
                val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
                permissionResult?.success(if (granted) "granted" else "denied")
                permissionResult = null
                return true
            }
            PERMISSION_REQUEST_WRITE_CONTACTS -> {
                val readGranted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
                val writeGranted = grantResults.size > 1 && grantResults[1] == PackageManager.PERMISSION_GRANTED
                val status = when {
                    readGranted && writeGranted -> "granted"
                    readGranted -> "grantedReadOnly"
                    else -> "denied"
                }
                permissionResult?.success(status)
                permissionResult = null
                return true
            }
        }
        return false
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        coroutineScope.cancel()
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}