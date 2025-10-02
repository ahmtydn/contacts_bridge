import 'package:contacts_bridge/src/core/error/failures.dart';
import 'package:contacts_bridge/src/core/utils/result.dart';
import 'package:contacts_bridge/src/domain/entities/contact.dart';
import 'package:contacts_bridge/src/domain/usecases/base_usecase.dart';

/// Parameters for creating a contact
class CreateContactParams {
  /// Creates CreateContactParams with the given contact
  const CreateContactParams({required this.contact});

  /// The contact to be created
  final Contact contact;
}

/// Use case for creating a new contact
class CreateContactUseCase extends UseCase<Contact, CreateContactParams> {
  /// Creates a CreateContactUseCase with the given repository
  const CreateContactUseCase(super.repository);

  @override
  Future<Result<Contact>> call(CreateContactParams params) async {
    // Validate contact data
    final validationResult = _validateContact(params.contact);
    if (validationResult != null) {
      return Failed(validationResult);
    }

    // Check permission
    final permissionResult = await repository.getPermissionStatus();
    if (permissionResult.isFailure) {
      return Failed(permissionResult.failure!);
    }

    final permission = permissionResult.value!;
    if (!permission.canWrite) {
      // Try to request write permission
      final requestResult = await repository.requestPermission();
      if (requestResult.isFailure) {
        return Failed(requestResult.failure!);
      }

      final newPermission = requestResult.value!;
      if (!newPermission.canWrite) {
        return const Failed(PermissionFailure('Contact write access denied'));
      }
    }

    // Create the contact
    return repository.createContact(params.contact);
  }

  /// Validates the contact data before creation
  Failure? _validateContact(Contact contact) {
    // A contact must have at least a display name or a structured name
    if (contact.displayName.isEmpty && contact.name.displayName.isEmpty) {
      return const InvalidContactDataFailure(
        'Contact must have a display name',
      );
    }

    // Validate phone numbers
    for (final phone in contact.phones) {
      if (phone.number.isEmpty) {
        return const InvalidContactDataFailure('Phone number cannot be empty');
      }
    }

    // Validate email addresses
    for (final email in contact.emails) {
      if (email.address.isEmpty) {
        return const InvalidContactDataFailure('Email address cannot be empty');
      }
      if (!email.isValid) {
        return InvalidContactDataFailure(
          'Invalid email address: ${email.address}',
        );
      }
    }

    // Validate addresses
    for (final address in contact.addresses) {
      if (!address.isValid) {
        return const InvalidContactDataFailure(
          'Address must have at least one field filled',
        );
      }
    }

    return null;
  }
}
