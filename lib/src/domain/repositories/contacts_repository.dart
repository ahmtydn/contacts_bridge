import 'package:contacts_bridge/src/core/utils/result.dart';
import 'package:contacts_bridge/src/domain/entities/contact.dart';
import 'package:contacts_bridge/src/domain/entities/permission_status.dart';

/// Abstract repository interface for contact operations
/// This follows the Repository pattern and Dependency Inversion Principle
abstract class ContactsRepository {
  /// Requests permission to access contacts
  ///
  /// [readOnly] - If true, requests read-only permission (Android only)
  /// Returns the new permission status
  Future<Result<PermissionStatus>> requestPermission({bool readOnly = false});

  /// Gets the current permission status
  Future<Result<PermissionStatus>> getPermissionStatus();

  /// Fetches all contacts from the device
  ///
  /// [withProperties] - Whether to fetch detailed properties
  /// [withThumbnail] - Whether to fetch low-res thumbnails
  /// [withPhoto] - Whether to fetch high-res photos
  /// [sorted] - Whether to sort contacts by display name
  Future<Result<List<Contact>>> getAllContacts({
    bool withProperties = false,
    bool withThumbnail = false,
    bool withPhoto = false,
    bool sorted = true,
  });

  /// Fetches a single contact by ID
  ///
  /// [id] - The unique identifier of the contact
  /// [withProperties] - Whether to fetch detailed properties
  /// [withThumbnail] - Whether to fetch low-res thumbnail
  /// [withPhoto] - Whether to fetch high-res photo
  Future<Result<Contact?>> getContact(
    String id, {
    bool withProperties = true,
    bool withThumbnail = false,
    bool withPhoto = false,
  });

  /// Searches for contacts by query string
  ///
  /// [query] - The search query (name, phone, email, etc.)
  /// [withProperties] - Whether to fetch detailed properties
  /// [sorted] - Whether to sort results by relevance
  Future<Result<List<Contact>>> searchContacts(
    String query, {
    bool withProperties = false,
    bool sorted = true,
  });

  /// Creates a new contact
  ///
  /// [contact] - The contact to create
  /// Returns the created contact with assigned ID
  Future<Result<Contact>> createContact(Contact contact);

  /// Updates an existing contact
  ///
  /// [contact] - The contact with updated information
  /// Returns the updated contact
  Future<Result<Contact>> updateContact(Contact contact);

  /// Deletes a contact by ID
  ///
  /// [id] - The unique identifier of the contact to delete
  Future<Result<void>> deleteContact(String id);

  /// Deletes multiple contacts by their IDs
  ///
  /// [ids] - List of contact IDs to delete
  Future<Result<void>> deleteContacts(List<String> ids);

  /// Gets all available contact groups
  Future<Result<List<String>>> getGroups();

  /// Adds a contact to a group
  ///
  /// [contactId] - The contact ID
  /// [groupId] - The group ID
  Future<Result<void>> addContactToGroup(String contactId, String groupId);

  /// Removes a contact from a group
  ///
  /// [contactId] - The contact ID
  /// [groupId] - The group ID
  Future<Result<void>> removeContactFromGroup(String contactId, String groupId);

  /// Observes changes to contacts
  /// Returns a stream that emits when contacts are modified
  Stream<List<Contact>> observeContacts();

  /// Opens the native contact picker
  /// Returns the selected contact or null if cancelled
  Future<Result<Contact?>> pickContact();

  /// Opens the native contact editor for a specific contact
  ///
  /// [contact] - The contact to edit
  /// Returns the updated contact or null if cancelled
  Future<Result<Contact?>> editContact(Contact contact);

  /// Opens the native contact view for a specific contact
  ///
  /// [contact] - The contact to view
  Future<Result<void>> viewContact(Contact contact);
}
