import 'package:contacts_bridge/src/core/error/failures.dart';
import 'package:contacts_bridge/src/core/utils/result.dart';
import 'package:contacts_bridge/src/domain/entities/contact.dart';
import 'package:contacts_bridge/src/domain/usecases/base_usecase.dart';

/// Parameters for getting a single contact
class GetContactParams {
  /// Creates GetContactParams with the given parameters
  const GetContactParams({
    required this.id,
    this.withProperties = true,
    this.withThumbnail = false,
    this.withPhoto = false,
  });

  /// The ID of the contact to retrieve
  final String id;

  /// Whether to include additional contact properties
  final bool withProperties;

  /// Whether to include contact thumbnail
  final bool withThumbnail;

  /// Whether to include full contact photo
  final bool withPhoto;
}

/// Use case for fetching a single contact by ID
class GetContactUseCase extends UseCase<Contact?, GetContactParams> {
  /// Creates a GetContactUseCase with the given repository
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
