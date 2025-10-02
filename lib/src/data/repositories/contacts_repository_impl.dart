import 'dart:async';

import 'package:contacts_bridge/plugin/contacts_bridge_platform_interface.dart';
import 'package:contacts_bridge/src/core/error/failures.dart';
import 'package:contacts_bridge/src/core/utils/result.dart';
import 'package:contacts_bridge/src/domain/entities/contact.dart';
import 'package:contacts_bridge/src/domain/entities/permission_status.dart';
import 'package:contacts_bridge/src/domain/repositories/contacts_repository.dart';

/// Implementation of ContactsRepository that uses the platform interface
/// This class follows the Repository pattern and acts as a bridge between
/// the domain layer and the platform-specific implementation
class ContactsRepositoryImpl implements ContactsRepository {
  const ContactsRepositoryImpl(this._platform);

  final ContactsBridgePlatform _platform;

  @override
  Future<Result<PermissionStatus>> requestPermission({
    bool readOnly = false,
  }) async {
    try {
      final status = await _platform.requestPermission(readOnly: readOnly);
      return Success(status);
    } catch (e) {
      return Failed(PlatformFailure('Failed to request permission: $e'));
    }
  }

  @override
  Future<Result<PermissionStatus>> getPermissionStatus() async {
    try {
      final status = await _platform.getPermissionStatus();
      return Success(status);
    } catch (e) {
      return Failed(PlatformFailure('Failed to get permission status: $e'));
    }
  }

  @override
  Future<Result<List<Contact>>> getAllContacts({
    bool withProperties = false,
    bool withThumbnail = false,
    bool withPhoto = false,
    bool sorted = true,
  }) async {
    try {
      final contacts = await _platform.getAllContacts(
        withProperties: withProperties,
        withThumbnail: withThumbnail,
        withPhoto: withPhoto,
        sorted: sorted,
      );
      return Success(contacts);
    } catch (e) {
      return Failed(PlatformFailure('Failed to get contacts: $e'));
    }
  }

  @override
  Future<Result<Contact?>> getContact(
    String id, {
    bool withProperties = true,
    bool withThumbnail = false,
    bool withPhoto = false,
  }) async {
    try {
      final contact = await _platform.getContact(
        id,
        withProperties: withProperties,
        withThumbnail: withThumbnail,
        withPhoto: withPhoto,
      );
      return Success(contact);
    } catch (e) {
      return Failed(ContactNotFoundFailure('Failed to get contact: $e'));
    }
  }

  @override
  Future<Result<List<Contact>>> searchContacts(
    String query, {
    bool withProperties = false,
    bool sorted = true,
  }) async {
    try {
      final contacts = await _platform.searchContacts(
        query,
        withProperties: withProperties,
        sorted: sorted,
      );
      return Success(contacts);
    } catch (e) {
      return Failed(PlatformFailure('Failed to search contacts: $e'));
    }
  }

  @override
  Future<Result<Contact>> createContact(Contact contact) async {
    try {
      final createdContact = await _platform.createContact(contact);
      return Success(createdContact);
    } catch (e) {
      return Failed(PlatformFailure('Failed to create contact: $e'));
    }
  }

  @override
  Future<Result<Contact>> updateContact(Contact contact) async {
    try {
      final updatedContact = await _platform.updateContact(contact);
      return Success(updatedContact);
    } catch (e) {
      return Failed(PlatformFailure('Failed to update contact: $e'));
    }
  }

  @override
  Future<Result<void>> deleteContact(String id) async {
    try {
      await _platform.deleteContact(id);
      return const Success(null);
    } catch (e) {
      return Failed(PlatformFailure('Failed to delete contact: $e'));
    }
  }

  @override
  Future<Result<void>> deleteContacts(List<String> ids) async {
    try {
      // Platform interface doesn't have batch delete, so we'll do it one by one
      for (final id in ids) {
        await _platform.deleteContact(id);
      }
      return const Success(null);
    } catch (e) {
      return Failed(PlatformFailure('Failed to delete contacts: $e'));
    }
  }

  @override
  Future<Result<List<String>>> getGroups() async {
    // TODO: Implement when platform supports groups
    return const Failed(PlatformFailure('Groups not yet implemented'));
  }

  @override
  Future<Result<void>> addContactToGroup(
    String contactId,
    String groupId,
  ) async {
    // TODO: Implement when platform supports groups
    return const Failed(PlatformFailure('Groups not yet implemented'));
  }

  @override
  Future<Result<void>> removeContactFromGroup(
    String contactId,
    String groupId,
  ) async {
    // TODO: Implement when platform supports groups
    return const Failed(PlatformFailure('Groups not yet implemented'));
  }

  @override
  Stream<List<Contact>> observeContacts() {
    try {
      return _platform.observeContacts();
    } catch (e) {
      return Stream.error(PlatformFailure('Failed to observe contacts: $e'));
    }
  }

  @override
  Future<Result<Contact?>> pickContact() async {
    // TODO: Implement when platform supports contact picker
    return const Failed(PlatformFailure('Contact picker not yet implemented'));
  }

  @override
  Future<Result<Contact?>> editContact(Contact contact) async {
    // TODO: Implement when platform supports contact editor
    return const Failed(PlatformFailure('Contact editor not yet implemented'));
  }

  @override
  Future<Result<void>> viewContact(Contact contact) async {
    // TODO: Implement when platform supports contact viewer
    return const Failed(PlatformFailure('Contact viewer not yet implemented'));
  }
}
