import 'package:contacts_bridge/plugin/contacts_bridge_platform_interface.dart';
import 'package:contacts_bridge/src/core/utils/result.dart';
import 'package:contacts_bridge/src/data/repositories/contacts_repository_impl.dart';
import 'package:contacts_bridge/src/domain/entities/contact.dart';
import 'package:contacts_bridge/src/domain/entities/permission_status.dart';
import 'package:contacts_bridge/src/domain/repositories/contacts_repository.dart';
import 'package:contacts_bridge/src/domain/usecases/create_contact_usecase.dart';
import 'package:contacts_bridge/src/domain/usecases/get_contact_usecase.dart';
import 'package:contacts_bridge/src/domain/usecases/get_contacts_usecase.dart';

/// Main plugin class that provides a clean API for contact operations
///
/// This class follows the Facade pattern and provides a simplified interface
/// to the complex contact management system underneath.
class ContactsBridge {
  /// Gets the singleton instance of ContactsBridge
  ///
  /// This ensures only one instance of ContactsBridge exists throughout
  /// the application lifecycle for consistent state management.
  factory ContactsBridge() => _instance ??= ContactsBridge._();
  ContactsBridge._();

  static ContactsBridge? _instance;

  late final ContactsRepository _repository;
  late final GetContactsUseCase _getContactsUseCase;
  late final GetContactUseCase _getContactUseCase;
  late final CreateContactUseCase _createContactUseCase;

  bool _isInitialized = false;

  /// Initialize the plugin with dependency injection
  void _initialize() {
    if (_isInitialized) return;

    _repository = ContactsRepositoryImpl(ContactsBridgePlatform.instance);
    _getContactsUseCase = GetContactsUseCase(_repository);
    _getContactUseCase = GetContactUseCase(_repository);
    _createContactUseCase = CreateContactUseCase(_repository);
    _isInitialized = true;
  }

  /// Ensure the plugin is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      _initialize();
    }
  }

  /// Gets the platform version for debugging purposes
  Future<String?> getPlatformVersion() {
    return ContactsBridgePlatform.instance.getPlatformVersion();
  }

  /// Requests permission to access contacts
  ///
  /// [readOnly] - If true, requests read-only access (Android only)
  /// Returns the permission status after the request
  Future<Result<PermissionStatus>> requestPermission({
    bool readOnly = false,
  }) async {
    _ensureInitialized();
    return _repository.requestPermission(readOnly: readOnly);
  }

  /// Gets the current permission status
  Future<Result<PermissionStatus>> getPermissionStatus() async {
    _ensureInitialized();
    return _repository.getPermissionStatus();
  }

  /// Fetches all contacts from the device
  ///
  /// [withProperties] - Whether to include detailed contact properties
  /// [withThumbnail] - Whether to include low-resolution thumbnails
  /// [withPhoto] - Whether to include high-resolution photos
  /// [sorted] - Whether to sort contacts by display name
  Future<Result<List<Contact>>> getAllContacts({
    bool withProperties = false,
    bool withThumbnail = false,
    bool withPhoto = false,
    bool sorted = true,
  }) async {
    _ensureInitialized();
    return _getContactsUseCase.call(
      GetContactsParams(
        withProperties: withProperties,
        withThumbnail: withThumbnail,
        withPhoto: withPhoto,
        sorted: sorted,
      ),
    );
  }

  /// Fetches a single contact by ID
  ///
  /// [id] - The unique identifier of the contact
  /// [withProperties] - Whether to include detailed properties
  /// [withThumbnail] - Whether to include low-resolution thumbnail
  /// [withPhoto] - Whether to include high-resolution photo
  Future<Result<Contact?>> getContact(
    String id, {
    bool withProperties = true,
    bool withThumbnail = false,
    bool withPhoto = false,
  }) async {
    _ensureInitialized();
    return _getContactUseCase.call(
      GetContactParams(
        id: id,
        withProperties: withProperties,
        withThumbnail: withThumbnail,
        withPhoto: withPhoto,
      ),
    );
  }

  /// Searches for contacts by query string
  ///
  /// [query] - The search query (name, phone, email, etc.)
  /// [withProperties] - Whether to include detailed properties
  /// [sorted] - Whether to sort results by relevance
  Future<Result<List<Contact>>> searchContacts(
    String query, {
    bool withProperties = false,
    bool sorted = true,
  }) async {
    _ensureInitialized();
    return _repository.searchContacts(
      query,
      withProperties: withProperties,
      sorted: sorted,
    );
  }

  /// Creates a new contact
  ///
  /// [contact] - The contact to create
  /// Returns the created contact with assigned ID
  Future<Result<Contact>> createContact(Contact contact) async {
    _ensureInitialized();
    return _createContactUseCase.call(
      CreateContactParams(contact: contact),
    );
  }

  /// Updates an existing contact
  ///
  /// [contact] - The contact with updated information
  /// Returns the updated contact
  Future<Result<Contact>> updateContact(Contact contact) async {
    _ensureInitialized();
    return _repository.updateContact(contact);
  }

  /// Deletes a contact by ID
  ///
  /// [id] - The unique identifier of the contact to delete
  Future<Result<void>> deleteContact(String id) async {
    _ensureInitialized();
    return _repository.deleteContact(id);
  }

  /// Observes changes to contacts
  /// Returns a stream that emits when contacts are modified
  Stream<List<Contact>> observeContacts() {
    _ensureInitialized();
    return _repository.observeContacts();
  }

  /// Opens the native contact picker
  /// Returns the selected contact or null if cancelled
  Future<Result<Contact?>> pickContact() async {
    _ensureInitialized();
    return _repository.pickContact();
  }
}
