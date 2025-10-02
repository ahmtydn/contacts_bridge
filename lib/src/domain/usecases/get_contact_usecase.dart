import 'package:contacts_bridge/src/core/error/failures.dart';
import 'package:contacts_bridge/src/core/utils/result.dart';
import 'package:contacts_bridge/src/domain/entities/contact.dart';
import 'package:contacts_bridge/src/domain/usecases/base_usecase.dart';

/// Parameters for getting a single contact
class GetContactParams {
  const GetContactParams({
    required this.id,
    this.withProperties = true,
    this.withThumbnail = false,
    this.withPhoto = false,
  });

  final String id;
  final bool withProperties;
  final bool withThumbnail;
  final bool withPhoto;
}

/// Use case for fetching a single contact by ID
class GetContactUseCase extends UseCase<Contact?, GetContactParams> {
  const GetContactUseCase(super.repository);

  @override
  Future<Result<Contact?>> call(GetContactParams params) async {
    if (params.id.isEmpty) {
      return const Failed(
        InvalidContactDataFailure('Contact ID cannot be empty'),
      );
    }

    // Check permission
    final permissionResult = await repository.getPermissionStatus();
    if (permissionResult.isFailure) {
      return Failed(permissionResult.failure!);
    }

    final permission = permissionResult.value!;
    if (!permission.canRead) {
      return const Failed(PermissionFailure('Contact read access denied'));
    }

    // Fetch the contact
    return repository.getContact(
      params.id,
      withProperties: params.withProperties,
      withThumbnail: params.withThumbnail,
      withPhoto: params.withPhoto,
    );
  }
}
