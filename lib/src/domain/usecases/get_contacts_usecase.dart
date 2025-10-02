import 'package:contacts_bridge/src/core/error/failures.dart';
import 'package:contacts_bridge/src/core/utils/result.dart';
import 'package:contacts_bridge/src/domain/entities/contact.dart';
import 'package:contacts_bridge/src/domain/usecases/base_usecase.dart';

/// Parameters for getting contacts
class GetContactsParams {
  /// Creates GetContactsParams with the given options
  const GetContactsParams({
    this.withProperties = false,
    this.withThumbnail = false,
    this.withPhoto = false,
    this.sorted = true,
  });

  /// Whether to include additional contact properties
  final bool withProperties;

  /// Whether to include contact thumbnails
  final bool withThumbnail;

  /// Whether to include full contact photos
  final bool withPhoto;

  /// Whether to sort the contacts
  final bool sorted;
}

/// Use case for fetching all contacts
class GetContactsUseCase extends UseCase<List<Contact>, GetContactsParams> {
  /// Creates a GetContactsUseCase with the given repository
  const GetContactsUseCase(super.repository);

  @override
  Future<Result<List<Contact>>> call(GetContactsParams params) async {
    // First check if we have permission
    final permissionResult = await repository.getPermissionStatus();
    if (permissionResult.isFailure) {
      return Failed(permissionResult.failure!);
    }

    final permission = permissionResult.value!;
    if (!permission.canRead) {
      // Try to request permission
      final requestResult = await repository.requestPermission();
      if (requestResult.isFailure) {
        return Failed(requestResult.failure!);
      }

      final newPermission = requestResult.value!;
      if (!newPermission.canRead) {
        return const Failed(PermissionFailure('Contact access denied'));
      }
    }

    // Fetch the contacts
    return repository.getAllContacts(
      withProperties: params.withProperties,
      withThumbnail: params.withThumbnail,
      withPhoto: params.withPhoto,
      sorted: params.sorted,
    );
  }
}
