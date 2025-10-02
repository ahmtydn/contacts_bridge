package com.ahmtydn.contacts_bridge

import android.content.ContentResolver
import android.content.ContentUris
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds.*
import android.provider.ContactsContract.Data
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

fun ContactsBridgePlugin.handleGetAllContacts(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any> ?: mapOf()
    val withProperties = args["withProperties"] as? Boolean ?: false
    val withThumbnail = args["withThumbnail"] as? Boolean ?: false
    val withPhoto = args["withPhoto"] as? Boolean ?: false
    val sorted = args["sorted"] as? Boolean ?: true

    coroutineScope.launch(Dispatchers.IO) {
        try {
            val contacts = getAllContacts(withProperties, withThumbnail, withPhoto, sorted)
            withContext(Dispatchers.Main) {
                result.success(contacts)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("FETCH_ERROR", "Failed to fetch contacts", e.message)
            }
        }
    }
}

fun ContactsBridgePlugin.handleGetContact(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any>
    val contactId = args?.get("id") as? String

    if (contactId == null) {
        result.error("INVALID_ARGUMENTS", "Contact ID is required", null)
        return
    }

    val withProperties = args["withProperties"] as? Boolean ?: true
    val withThumbnail = args["withThumbnail"] as? Boolean ?: false
    val withPhoto = args["withPhoto"] as? Boolean ?: false

    coroutineScope.launch(Dispatchers.IO) {
        try {
            val contact = getContact(contactId, withProperties, withThumbnail, withPhoto)
            withContext(Dispatchers.Main) {
                result.success(contact)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("FETCH_ERROR", "Failed to fetch contact", e.message)
            }
        }
    }
}

fun ContactsBridgePlugin.handleSearchContacts(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any>
    val query = args?.get("query") as? String

    if (query == null) {
        result.error("INVALID_ARGUMENTS", "Search query is required", null)
        return
    }

    val withProperties = args["withProperties"] as? Boolean ?: false
    val sorted = args["sorted"] as? Boolean ?: true

    coroutineScope.launch(Dispatchers.IO) {
        try {
            val contacts = searchContacts(query, withProperties, sorted)
            withContext(Dispatchers.Main) {
                result.success(contacts)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("SEARCH_ERROR", "Failed to search contacts", e.message)
            }
        }
    }
}

fun ContactsBridgePlugin.handleCreateContact(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any>
    val contactData = args?.get("contact") as? Map<String, Any>

    if (contactData == null) {
        result.error("INVALID_ARGUMENTS", "Contact data is required", null)
        return
    }

    coroutineScope.launch(Dispatchers.IO) {
        try {
            val contact = createContact(contactData)
            withContext(Dispatchers.Main) {
                result.success(contact)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("CREATE_ERROR", "Failed to create contact", e.message)
            }
        }
    }
}

fun ContactsBridgePlugin.handleUpdateContact(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any>
    val contactData = args?.get("contact") as? Map<String, Any>

    if (contactData == null) {
        result.error("INVALID_ARGUMENTS", "Contact data is required", null)
        return
    }

    coroutineScope.launch(Dispatchers.IO) {
        try {
            val contact = updateContact(contactData)
            withContext(Dispatchers.Main) {
                result.success(contact)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("UPDATE_ERROR", "Failed to update contact", e.message)
            }
        }
    }
}

fun ContactsBridgePlugin.handleDeleteContact(call: MethodCall, result: Result) {
    val args = call.arguments as? Map<String, Any>
    val contactId = args?.get("id") as? String

    if (contactId == null) {
        result.error("INVALID_ARGUMENTS", "Contact ID is required", null)
        return
    }

    coroutineScope.launch(Dispatchers.IO) {
        try {
            deleteContact(contactId)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("DELETE_ERROR", "Failed to delete contact", e.message)
            }
        }
    }
}