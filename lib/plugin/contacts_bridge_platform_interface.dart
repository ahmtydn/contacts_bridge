import 'package:contacts_bridge/plugin/contacts_bridge_method_channel.dart';
import 'package:contacts_bridge/src/domain/entities/contact.dart';
import 'package:contacts_bridge/src/domain/entities/permission_status.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of contacts_bridge must implement.
abstract class ContactsBridgePlatform extends PlatformInterface {
  /// Constructs a ContactsBridgePlatform.
  ContactsBridgePlatform() : super(token: _token);

  static final Object _token = Object();

  static ContactsBridgePlatform _instance = MethodChannelContactsBridge();

  /// The default instance of [ContactsBridgePlatform] to use.
  ///
  /// Defaults to [MethodChannelContactsBridge].
  static ContactsBridgePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ContactsBridgePlatform] when
  /// they register themselves.
  static set instance(ContactsBridgePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gets the platform version.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Requests permission to access contacts.
  ///
  /// [readOnly] - If true, requests read-only permission.
  Future<PermissionStatus> requestPermission({bool readOnly = false}) {
    throw UnimplementedError('requestPermission() has not been implemented.');
  }

  /// Gets the current permission status for contacts access.
  Future<PermissionStatus> getPermissionStatus() {
    throw UnimplementedError('getPermissionStatus() has not been implemented.');
  }

  /// Gets all contacts from the device.
  ///
  /// [withProperties] - Include phone numbers, emails, etc.
  /// [withThumbnail] - Include thumbnail images.
  /// [withPhoto] - Include full-size photos.
  /// [sorted] - Sort contacts alphabetically.
  Future<List<Contact>> getAllContacts({
    bool withProperties = false,
    bool withThumbnail = false,
    bool withPhoto = false,
    bool sorted = true,
  }) {
    throw UnimplementedError('getAllContacts() has not been implemented.');
  }

  /// Gets a specific contact by ID.
  ///
  /// [id] - The contact ID to retrieve.
  /// [withProperties] - Include phone numbers, emails, etc.
  /// [withThumbnail] - Include thumbnail image.
  /// [withPhoto] - Include full-size photo.
  Future<Contact?> getContact(
    String id, {
    bool withProperties = true,
    bool withThumbnail = false,
    bool withPhoto = false,
  }) {
    throw UnimplementedError('getContact() has not been implemented.');
  }

  /// Searches for contacts matching the given query.
  ///
  /// [query] - The search term to match against contact names.
  /// [withProperties] - Include phone numbers, emails, etc.
  /// [sorted] - Sort results alphabetically.
  Future<List<Contact>> searchContacts(
    String query, {
    bool withProperties = false,
    bool sorted = true,
  }) {
    throw UnimplementedError('searchContacts() has not been implemented.');
  }

  /// Creates a new contact.
  ///
  /// [contact] - The contact data to create.
  Future<Contact> createContact(Contact contact) {
    throw UnimplementedError('createContact() has not been implemented.');
  }

  /// Updates an existing contact.
  ///
  /// [contact] - The contact data with updates.
  Future<Contact> updateContact(Contact contact) {
    throw UnimplementedError('updateContact() has not been implemented.');
  }

  /// Deletes a contact by ID.
  ///
  /// [id] - The ID of the contact to delete.
  Future<void> deleteContact(String id) {
    throw UnimplementedError('deleteContact() has not been implemented.');
  }

  /// Observes changes to the contacts database.
  ///
  /// Returns a stream of contact lists that updates when contacts change.
  Stream<List<Contact>> observeContacts() {
    throw UnimplementedError('observeContacts() has not been implemented.');
  }
}
