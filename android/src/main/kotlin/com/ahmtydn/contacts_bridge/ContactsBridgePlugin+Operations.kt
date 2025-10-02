package com.ahmtydn.contacts_bridge

import android.annotation.SuppressLint
import android.content.ContentProviderOperation
import android.content.ContentUris
import android.content.ContentValues
import android.database.Cursor
import android.net.Uri
import android.provider.ContactsContract
import android.provider.ContactsContract.CommonDataKinds.*
import android.provider.ContactsContract.Data
import android.provider.ContactsContract.RawContacts
import java.io.ByteArrayOutputStream
import java.io.InputStream

@SuppressLint("Range")
fun ContactsBridgePlugin.getAllContacts(
    withProperties: Boolean,
    withThumbnail: Boolean,
    withPhoto: Boolean,
    sorted: Boolean
): List<Map<String, Any?>> {
    val resolver = this.resolver ?: return emptyList()
    val contacts = mutableListOf<Map<String, Any?>>()
    
    val projection = arrayOf(
        ContactsContract.Contacts._ID,
        ContactsContract.Contacts.LOOKUP_KEY,
        ContactsContract.Contacts.DISPLAY_NAME_PRIMARY,
        ContactsContract.Contacts.HAS_PHONE_NUMBER,
        ContactsContract.Contacts.STARRED
    )
    
    val sortOrder = if (sorted) "${ContactsContract.Contacts.DISPLAY_NAME_PRIMARY} ASC" else null
    
    val cursor = resolver.query(
        ContactsContract.Contacts.CONTENT_URI,
        projection,
        null,
        null,
        sortOrder
    )
    
    cursor?.use { cursor ->
        while (cursor.moveToNext()) {
            val contactId = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID))
            val displayName = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME_PRIMARY)) ?: ""
            val isStarred = cursor.getInt(cursor.getColumnIndex(ContactsContract.Contacts.STARRED)) == 1
            
            val contact = mutableMapOf<String, Any?>(
                "id" to contactId,
                "displayName" to displayName,
                "isStarred" to isStarred,
                "propertiesFetched" to withProperties,
                "thumbnailFetched" to withThumbnail,
                "photoFetched" to withPhoto
            )
            
            if (withProperties) {
                contact.putAll(getContactProperties(resolver, contactId))
            }
            
            if (withThumbnail) {
                contact["thumbnail"] = getContactThumbnail(resolver, contactId)
            }
            
            if (withPhoto) {
                contact["photo"] = getContactPhoto(resolver, contactId)
            }
            
            contacts.add(contact)
        }
    }
    
    return contacts
}

@SuppressLint("Range")
fun ContactsBridgePlugin.getContact(
    contactId: String,
    withProperties: Boolean,
    withThumbnail: Boolean,
    withPhoto: Boolean
): Map<String, Any?>? {
    val resolver = this.resolver ?: return null
    
    val projection = arrayOf(
        ContactsContract.Contacts._ID,
        ContactsContract.Contacts.LOOKUP_KEY,
        ContactsContract.Contacts.DISPLAY_NAME_PRIMARY,
        ContactsContract.Contacts.HAS_PHONE_NUMBER,
        ContactsContract.Contacts.STARRED
    )
    
    val cursor = resolver.query(
        ContactsContract.Contacts.CONTENT_URI,
        projection,
        "${ContactsContract.Contacts._ID} = ?",
        arrayOf(contactId),
        null
    )
    
    cursor?.use { cursor ->
        if (cursor.moveToFirst()) {
            val displayName = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME_PRIMARY)) ?: ""
            val isStarred = cursor.getInt(cursor.getColumnIndex(ContactsContract.Contacts.STARRED)) == 1
            
            val contact = mutableMapOf<String, Any?>(
                "id" to contactId,
                "displayName" to displayName,
                "isStarred" to isStarred,
                "propertiesFetched" to withProperties,
                "thumbnailFetched" to withThumbnail,
                "photoFetched" to withPhoto
            )
            
            if (withProperties) {
                contact.putAll(getContactProperties(resolver, contactId))
            }
            
            if (withThumbnail) {
                contact["thumbnail"] = getContactThumbnail(resolver, contactId)
            }
            
            if (withPhoto) {
                contact["photo"] = getContactPhoto(resolver, contactId)
            }
            
            return contact
        }
    }
    
    return null
}

fun ContactsBridgePlugin.searchContacts(
    query: String,
    withProperties: Boolean,
    sorted: Boolean
): List<Map<String, Any?>> {
    val resolver = this.resolver ?: return emptyList()
    val contacts = mutableListOf<Map<String, Any?>>()
    
    val projection = arrayOf(
        ContactsContract.Contacts._ID,
        ContactsContract.Contacts.LOOKUP_KEY,
        ContactsContract.Contacts.DISPLAY_NAME_PRIMARY,
        ContactsContract.Contacts.HAS_PHONE_NUMBER,
        ContactsContract.Contacts.STARRED
    )
    
    val selection = "${ContactsContract.Contacts.DISPLAY_NAME_PRIMARY} LIKE ?"
    val selectionArgs = arrayOf("%$query%")
    val sortOrder = if (sorted) "${ContactsContract.Contacts.DISPLAY_NAME_PRIMARY} ASC" else null
    
    val cursor = resolver.query(
        ContactsContract.Contacts.CONTENT_URI,
        projection,
        selection,
        selectionArgs,
        sortOrder
    )
    
    cursor?.use { cursor ->
        while (cursor.moveToNext()) {
            val contactId = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID))
            val displayName = cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME_PRIMARY)) ?: ""
            val isStarred = cursor.getInt(cursor.getColumnIndex(ContactsContract.Contacts.STARRED)) == 1
            
            val contact = mutableMapOf<String, Any?>(
                "id" to contactId,
                "displayName" to displayName,
                "isStarred" to isStarred,
                "propertiesFetched" to withProperties,
                "thumbnailFetched" to false,
                "photoFetched" to false
            )
            
            if (withProperties) {
                contact.putAll(getContactProperties(resolver, contactId))
            }
            
            contacts.add(contact)
        }
    }
    
    return contacts
}

fun ContactsBridgePlugin.createContact(contactData: Map<String, Any>): Map<String, Any?> {
    val resolver = this.resolver ?: throw Exception("ContentResolver not available")
    val operations = mutableListOf<ContentProviderOperation>()
    
    // Create raw contact
    operations.add(
        ContentProviderOperation.newInsert(RawContacts.CONTENT_URI)
            .withValue(RawContacts.ACCOUNT_TYPE, null as String?)
            .withValue(RawContacts.ACCOUNT_NAME, null as String?)
            .build()
    )
    
    // Add structured name
    val name = contactData["name"] as? Map<String, Any>
    if (name != null) {
        val nameOp = ContentProviderOperation.newInsert(Data.CONTENT_URI)
            .withValueBackReference(Data.RAW_CONTACT_ID, 0)
            .withValue(Data.MIMETYPE, StructuredName.CONTENT_ITEM_TYPE)
        
        name["givenName"]?.let { nameOp.withValue(StructuredName.GIVEN_NAME, it) }
        name["familyName"]?.let { nameOp.withValue(StructuredName.FAMILY_NAME, it) }
        name["middleName"]?.let { nameOp.withValue(StructuredName.MIDDLE_NAME, it) }
        name["namePrefix"]?.let { nameOp.withValue(StructuredName.PREFIX, it) }
        name["nameSuffix"]?.let { nameOp.withValue(StructuredName.SUFFIX, it) }
        
        operations.add(nameOp.build())
    }
    
    // Add phone numbers
    val phones = contactData["phones"] as? List<Map<String, Any>>
    phones?.forEach { phone ->
        val number = phone["number"] as? String
        val type = getPhoneType(phone["label"] as? String)
        
        if (!number.isNullOrBlank()) {
            operations.add(
                ContentProviderOperation.newInsert(Data.CONTENT_URI)
                    .withValueBackReference(Data.RAW_CONTACT_ID, 0)
                    .withValue(Data.MIMETYPE, Phone.CONTENT_ITEM_TYPE)
                    .withValue(Phone.NUMBER, number)
                    .withValue(Phone.TYPE, type)
                    .build()
            )
        }
    }
    
    // Add email addresses
    val emails = contactData["emails"] as? List<Map<String, Any>>
    emails?.forEach { email ->
        val address = email["email"] as? String
        val type = getEmailType(email["label"] as? String)
        
        if (!address.isNullOrBlank()) {
            operations.add(
                ContentProviderOperation.newInsert(Data.CONTENT_URI)
                    .withValueBackReference(Data.RAW_CONTACT_ID, 0)
                    .withValue(Data.MIMETYPE, Email.CONTENT_ITEM_TYPE)
                    .withValue(Email.ADDRESS, address)
                    .withValue(Email.TYPE, type)
                    .build()
            )
        }
    }
    
    // Add organization
    val organization = contactData["organization"] as? Map<String, Any>
    if (organization != null) {
        val company = organization["name"] as? String
        val title = organization["jobTitle"] as? String
        
        if (!company.isNullOrBlank() || !title.isNullOrBlank()) {
            operations.add(
                ContentProviderOperation.newInsert(Data.CONTENT_URI)
                    .withValueBackReference(Data.RAW_CONTACT_ID, 0)
                    .withValue(Data.MIMETYPE, Organization.CONTENT_ITEM_TYPE)
                    .withValue(Organization.COMPANY, company)
                    .withValue(Organization.TITLE, title)
                    .build()
            )
        }
    }
    
    // Add note
    val note = contactData["note"] as? String
    if (!note.isNullOrBlank()) {
        operations.add(
            ContentProviderOperation.newInsert(Data.CONTENT_URI)
                .withValueBackReference(Data.RAW_CONTACT_ID, 0)
                .withValue(Data.MIMETYPE, Note.CONTENT_ITEM_TYPE)
                .withValue(Note.NOTE, note)
                .build()
        )
    }
    
    val results = resolver.applyBatch(ContactsContract.AUTHORITY, operations)
    val rawContactUri = results[0].uri
    val rawContactId = ContentUris.parseId(rawContactUri!!)
    
    // Get the contact ID from the raw contact ID
    val contactId = getContactIdFromRawContactId(resolver, rawContactId.toString())
    
    return getContact(contactId, true, false, false) ?: throw Exception("Failed to retrieve created contact")
}

fun ContactsBridgePlugin.updateContact(contactData: Map<String, Any>): Map<String, Any?> {
    val resolver = this.resolver ?: throw Exception("ContentResolver not available")
    val contactId = contactData["id"] as? String ?: throw Exception("Contact ID is required")
    
    // Implementation for updating contact - similar to create but with update operations
    // This is a simplified version - full implementation would handle all field updates
    
    return getContact(contactId, true, false, false) ?: throw Exception("Failed to retrieve updated contact")
}

fun ContactsBridgePlugin.deleteContact(contactId: String) {
    val resolver = this.resolver ?: throw Exception("ContentResolver not available")
    
    val contactUri = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, contactId.toLong())
    resolver.delete(contactUri, null, null)
}