package com.ahmtydn.contacts_bridge

import android.annotation.SuppressLint
import android.content.ContentResolver
import android.content.ContentUris
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds.*
import android.provider.ContactsContract.Data
import java.io.ByteArrayOutputStream
import java.io.InputStream

@SuppressLint("Range")
fun ContactsBridgePlugin.getContactProperties(resolver: ContentResolver, contactId: String): Map<String, Any?> {
    val properties = mutableMapOf<String, Any?>()
    
    // Get structured name
    properties["name"] = getStructuredName(resolver, contactId)
    
    // Get phone numbers
    properties["phones"] = getPhoneNumbers(resolver, contactId)
    
    // Get email addresses
    properties["emails"] = getEmailAddresses(resolver, contactId)
    
    // Get postal addresses
    properties["addresses"] = getPostalAddresses(resolver, contactId)
    
    // Get organization
    properties["organizations"] = getOrganizations(resolver, contactId)
    
    // Get websites
    properties["websites"] = getWebsites(resolver, contactId)
    
    // Get notes
    properties["notes"] = getNotes(resolver, contactId)
    
    // Get events
    properties["events"] = getEvents(resolver, contactId)
    
    return properties
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getStructuredName(resolver: ContentResolver, contactId: String): Map<String, String> {
    val name = mutableMapOf<String, String>()
    
    val cursor = resolver.query(
        Data.CONTENT_URI,
        arrayOf(
            StructuredName.GIVEN_NAME,
            StructuredName.FAMILY_NAME,
            StructuredName.MIDDLE_NAME,
            StructuredName.PREFIX,
            StructuredName.SUFFIX,
            StructuredName.DISPLAY_NAME
        ),
        "${Data.CONTACT_ID} = ? AND ${Data.MIMETYPE} = ?",
        arrayOf(contactId, StructuredName.CONTENT_ITEM_TYPE),
        null
    )
    
    cursor?.use { cursor ->
        if (cursor.moveToFirst()) {
            name["givenName"] = cursor.getString(cursor.getColumnIndex(StructuredName.GIVEN_NAME)) ?: ""
            name["familyName"] = cursor.getString(cursor.getColumnIndex(StructuredName.FAMILY_NAME)) ?: ""
            name["middleName"] = cursor.getString(cursor.getColumnIndex(StructuredName.MIDDLE_NAME)) ?: ""
            name["namePrefix"] = cursor.getString(cursor.getColumnIndex(StructuredName.PREFIX)) ?: ""
            name["nameSuffix"] = cursor.getString(cursor.getColumnIndex(StructuredName.SUFFIX)) ?: ""
        }
    }
    
    return name
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getPhoneNumbers(resolver: ContentResolver, contactId: String): List<Map<String, Any>> {
    val phones = mutableListOf<Map<String, Any>>()
    
    val cursor = resolver.query(
        Phone.CONTENT_URI,
        arrayOf(Phone.NUMBER, Phone.TYPE, Phone.LABEL),
        "${Phone.CONTACT_ID} = ?",
        arrayOf(contactId),
        null
    )
    
    cursor?.use { cursor ->
        while (cursor.moveToNext()) {
            val number = cursor.getString(cursor.getColumnIndex(Phone.NUMBER)) ?: ""
            val type = cursor.getInt(cursor.getColumnIndex(Phone.TYPE))
            val label = cursor.getString(cursor.getColumnIndex(Phone.LABEL)) ?: ""
            
            phones.add(mapOf(
                "number" to number,
                "normalizedNumber" to number.replace(Regex("[^0-9]"), ""),
                "label" to getPhoneLabel(type, label),
                "type" to type
            ))
        }
    }
    
    return phones
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getEmailAddresses(resolver: ContentResolver, contactId: String): List<Map<String, Any>> {
    val emails = mutableListOf<Map<String, Any>>()
    
    val cursor = resolver.query(
        Email.CONTENT_URI,
        arrayOf(Email.ADDRESS, Email.TYPE, Email.LABEL),
        "${Email.CONTACT_ID} = ?",
        arrayOf(contactId),
        null
    )
    
    cursor?.use { cursor ->
        while (cursor.moveToNext()) {
            val address = cursor.getString(cursor.getColumnIndex(Email.ADDRESS)) ?: ""
            val type = cursor.getInt(cursor.getColumnIndex(Email.TYPE))
            val label = cursor.getString(cursor.getColumnIndex(Email.LABEL)) ?: ""
            
            emails.add(mapOf(
                "email" to address,
                "label" to getEmailLabel(type, label),
                "type" to type
            ))
        }
    }
    
    return emails
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getPostalAddresses(resolver: ContentResolver, contactId: String): List<Map<String, Any>> {
    val addresses = mutableListOf<Map<String, Any>>()
    
    val cursor = resolver.query(
        StructuredPostal.CONTENT_URI,
        arrayOf(
            StructuredPostal.STREET,
            StructuredPostal.CITY,
            StructuredPostal.REGION,
            StructuredPostal.POSTCODE,
            StructuredPostal.COUNTRY,
            StructuredPostal.TYPE,
            StructuredPostal.LABEL
        ),
        "${StructuredPostal.CONTACT_ID} = ?",
        arrayOf(contactId),
        null
    )
    
    cursor?.use { cursor ->
        while (cursor.moveToNext()) {
            val street = cursor.getString(cursor.getColumnIndex(StructuredPostal.STREET)) ?: ""
            val city = cursor.getString(cursor.getColumnIndex(StructuredPostal.CITY)) ?: ""
            val state = cursor.getString(cursor.getColumnIndex(StructuredPostal.REGION)) ?: ""
            val postalCode = cursor.getString(cursor.getColumnIndex(StructuredPostal.POSTCODE)) ?: ""
            val country = cursor.getString(cursor.getColumnIndex(StructuredPostal.COUNTRY)) ?: ""
            val type = cursor.getInt(cursor.getColumnIndex(StructuredPostal.TYPE))
            val label = cursor.getString(cursor.getColumnIndex(StructuredPostal.LABEL)) ?: ""
            
            addresses.add(mapOf(
                "street" to street,
                "city" to city,
                "state" to state,
                "postalCode" to postalCode,
                "country" to country,
                "label" to getAddressLabel(type, label),
                "type" to type
            ))
        }
    }
    
    return addresses
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getOrganizations(resolver: ContentResolver, contactId: String): List<Map<String, Any>> {
    val organizations = mutableListOf<Map<String, Any>>()
    
    val cursor = resolver.query(
        Data.CONTENT_URI,
        arrayOf(Organization.COMPANY, Organization.TITLE, Organization.DEPARTMENT),
        "${Data.CONTACT_ID} = ? AND ${Data.MIMETYPE} = ?",
        arrayOf(contactId, Organization.CONTENT_ITEM_TYPE),
        null
    )
    
    cursor?.use { cursor ->
        while (cursor.moveToNext()) {
            val company = cursor.getString(cursor.getColumnIndex(Organization.COMPANY)) ?: ""
            val title = cursor.getString(cursor.getColumnIndex(Organization.TITLE)) ?: ""
            val department = cursor.getString(cursor.getColumnIndex(Organization.DEPARTMENT)) ?: ""
            
            if (company.isNotEmpty() || title.isNotEmpty() || department.isNotEmpty()) {
                organizations.add(mapOf(
                    "name" to company,
                    "jobTitle" to title,
                    "department" to department
                ))
            }
        }
    }
    
    return organizations
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getWebsites(resolver: ContentResolver, contactId: String): List<Map<String, Any>> {
    val websites = mutableListOf<Map<String, Any>>()
    
    val cursor = resolver.query(
        Data.CONTENT_URI,
        arrayOf(Website.URL, Website.TYPE, Website.LABEL),
        "${Data.CONTACT_ID} = ? AND ${Data.MIMETYPE} = ?",
        arrayOf(contactId, Website.CONTENT_ITEM_TYPE),
        null
    )
    
    cursor?.use { cursor ->
        while (cursor.moveToNext()) {
            val url = cursor.getString(cursor.getColumnIndex(Website.URL)) ?: ""
            val type = cursor.getInt(cursor.getColumnIndex(Website.TYPE))
            val label = cursor.getString(cursor.getColumnIndex(Website.LABEL)) ?: ""
            
            websites.add(mapOf(
                "url" to url,
                "label" to getWebsiteLabel(type, label),
                "type" to type
            ))
        }
    }
    
    return websites
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getNotes(resolver: ContentResolver, contactId: String): List<Map<String, Any>> {
    val notes = mutableListOf<Map<String, Any>>()
    
    val cursor = resolver.query(
        Data.CONTENT_URI,
        arrayOf(Note.NOTE),
        "${Data.CONTACT_ID} = ? AND ${Data.MIMETYPE} = ?",
        arrayOf(contactId, Note.CONTENT_ITEM_TYPE),
        null
    )
    
    cursor?.use { cursor ->
        while (cursor.moveToNext()) {
            val note = cursor.getString(cursor.getColumnIndex(Note.NOTE)) ?: ""
            if (note.isNotEmpty()) {
                notes.add(mapOf(
                    "note" to note
                ))
            }
        }
    }
    
    return notes
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getEvents(resolver: ContentResolver, contactId: String): List<Map<String, Any?>> {
    val events = mutableListOf<Map<String, Any?>>()
    
    val cursor = resolver.query(
        Data.CONTENT_URI,
        arrayOf(Event.START_DATE, Event.TYPE, Event.LABEL),
        "${Data.CONTACT_ID} = ? AND ${Data.MIMETYPE} = ?",
        arrayOf(contactId, Event.CONTENT_ITEM_TYPE),
        null
    )
    
    cursor?.use { cursor ->
        while (cursor.moveToNext()) {
            val startDate = cursor.getString(cursor.getColumnIndex(Event.START_DATE)) ?: ""
            val type = cursor.getInt(cursor.getColumnIndex(Event.TYPE))
            val label = cursor.getString(cursor.getColumnIndex(Event.LABEL)) ?: ""
            
            // Parse date (format: YYYY-MM-DD)
            val dateParts = startDate.split("-")
            val eventMap = mutableMapOf<String, Any?>(
                "label" to getEventLabel(type, label),
                "type" to type
            )
            
            if (dateParts.size >= 3) {
                eventMap["year"] = dateParts[0].toIntOrNull()
                eventMap["month"] = dateParts[1].toIntOrNull()
                eventMap["day"] = dateParts[2].toIntOrNull()
            }
            
            events.add(eventMap)
        }
    }
    
    return events
}

fun ContactsBridgePlugin.getContactThumbnail(resolver: ContentResolver, contactId: String): ByteArray? {
    val uri = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, contactId.toLong())
    val photoUri = Uri.withAppendedPath(uri, ContactsContract.Contacts.Photo.CONTENT_DIRECTORY)
    
    return try {
        val inputStream: InputStream? = resolver.openInputStream(photoUri)
        inputStream?.use { stream ->
            val buffer = ByteArrayOutputStream()
            val data = ByteArray(1024)
            var nRead: Int
            while (stream.read(data, 0, data.size).also { nRead = it } != -1) {
                buffer.write(data, 0, nRead)
            }
            buffer.toByteArray()
        }
    } catch (e: Exception) {
        null
    }
}

fun ContactsBridgePlugin.getContactPhoto(resolver: ContentResolver, contactId: String): ByteArray? {
    // For Android, photo and thumbnail are typically the same
    return getContactThumbnail(resolver, contactId)
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getContactIdFromRawContactId(resolver: ContentResolver, rawContactId: String): String {
    val cursor = resolver.query(
        ContactsContract.RawContacts.CONTENT_URI,
        arrayOf(ContactsContract.RawContacts.CONTACT_ID),
        "${ContactsContract.RawContacts._ID} = ?",
        arrayOf(rawContactId),
        null
    )
    
    cursor?.use { cursor ->
        if (cursor.moveToFirst()) {
            return cursor.getString(cursor.getColumnIndex(ContactsContract.RawContacts.CONTACT_ID))
        }
    }
    
    return rawContactId
}

// Label helper functions
fun getPhoneLabel(type: Int, customLabel: String): String {
    return when (type) {
        Phone.TYPE_HOME -> "home"
        Phone.TYPE_MOBILE -> "mobile"
        Phone.TYPE_WORK -> "work"
        Phone.TYPE_FAX_WORK -> "faxWork"
        Phone.TYPE_FAX_HOME -> "faxHome"
        Phone.TYPE_PAGER -> "pager"
        Phone.TYPE_OTHER -> "other"
        Phone.TYPE_MAIN -> "main"
        Phone.TYPE_CUSTOM -> customLabel.ifEmpty { "custom" }
        else -> "other"
    }
}

fun getPhoneType(label: String?): Int {
    return when (label?.lowercase()) {
        "home" -> Phone.TYPE_HOME
        "mobile", "cell" -> Phone.TYPE_MOBILE
        "work" -> Phone.TYPE_WORK
        "faxwork" -> Phone.TYPE_FAX_WORK
        "faxhome" -> Phone.TYPE_FAX_HOME
        "pager" -> Phone.TYPE_PAGER
        "main" -> Phone.TYPE_MAIN
        else -> Phone.TYPE_OTHER
    }
}

fun getEmailLabel(type: Int, customLabel: String): String {
    return when (type) {
        Email.TYPE_HOME -> "home"
        Email.TYPE_WORK -> "work"
        Email.TYPE_OTHER -> "other"
        Email.TYPE_MOBILE -> "mobile"
        Email.TYPE_CUSTOM -> customLabel.ifEmpty { "custom" }
        else -> "other"
    }
}

fun getEmailType(label: String?): Int {
    return when (label?.lowercase()) {
        "home" -> Email.TYPE_HOME
        "work" -> Email.TYPE_WORK
        "mobile" -> Email.TYPE_MOBILE
        else -> Email.TYPE_OTHER
    }
}

fun getAddressLabel(type: Int, customLabel: String): String {
    return when (type) {
        StructuredPostal.TYPE_HOME -> "home"
        StructuredPostal.TYPE_WORK -> "work"
        StructuredPostal.TYPE_OTHER -> "other"
        StructuredPostal.TYPE_CUSTOM -> customLabel.ifEmpty { "custom" }
        else -> "other"
    }
}

fun getWebsiteLabel(type: Int, customLabel: String): String {
    return when (type) {
        Website.TYPE_HOMEPAGE -> "homepage"
        Website.TYPE_BLOG -> "blog"
        Website.TYPE_PROFILE -> "profile"
        Website.TYPE_HOME -> "home"
        Website.TYPE_WORK -> "work"
        Website.TYPE_FTP -> "ftp"
        Website.TYPE_OTHER -> "other"
        Website.TYPE_CUSTOM -> customLabel.ifEmpty { "custom" }
        else -> "other"
    }
}

fun getEventLabel(type: Int, customLabel: String): String {
    return when (type) {
        Event.TYPE_BIRTHDAY -> "birthday"
        Event.TYPE_ANNIVERSARY -> "anniversary"
        Event.TYPE_OTHER -> "other"
        Event.TYPE_CUSTOM -> customLabel.ifEmpty { "custom" }
        else -> "other"
    }
}