import 'package:contacts_bridge/plugin/contacts_bridge_platform_interface.dart';
import 'package:contacts_bridge/src/domain/entities/contact.dart';
import 'package:contacts_bridge/src/domain/entities/permission_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of [ContactsBridgePlatform] that uses method channels.
class MethodChannelContactsBridge extends ContactsBridgePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('com.ahmtydn.contacts_bridge');

  /// The event channel used to observe contact changes from native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('com.ahmtydn.contacts_bridge/events');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<PermissionStatus> requestPermission({bool readOnly = false}) async {
    try {
      final result = await methodChannel.invokeMethod<String>(
        'requestPermission',
        {'readOnly': readOnly},
      );
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      final errorDetails =
          e.details?.toString() ?? e.message ?? 'Unknown error';
      throw Exception('Failed to request permission: $errorDetails');
    }
  }

  @override
  Future<PermissionStatus> getPermissionStatus() async {
    try {
      final result = await methodChannel.invokeMethod<String>(
        'getPermissionStatus',
      );
      return _parsePermissionStatus(result);
    } on PlatformException catch (e) {
      final errorDetails =
          e.details?.toString() ?? e.message ?? 'Unknown error';
      throw Exception('Failed to get permission status: $errorDetails');
    }
  }

  @override
  Future<List<Contact>> getAllContacts({
    bool withProperties = false,
    bool withThumbnail = false,
    bool withPhoto = false,
    bool sorted = true,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<List<dynamic>>(
        'getAllContacts',
        {
          'withProperties': withProperties,
          'withThumbnail': withThumbnail,
          'withPhoto': withPhoto,
          'sorted': sorted,
        },
      );

      return result
              ?.map<Contact>(
                (dynamic item) => Contact.fromJson(_safeMapCast(item)),
              )
              .toList() ??
          <Contact>[];
    } on PlatformException catch (e) {
      throw Exception('Failed to get contacts: ${e.message}');
    }
  }

  @override
  Future<Contact?> getContact(
    String id, {
    bool withProperties = true,
    bool withThumbnail = false,
    bool withPhoto = false,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<dynamic>(
        'getContact',
        {
          'id': id,
          'withProperties': withProperties,
          'withThumbnail': withThumbnail,
          'withPhoto': withPhoto,
        },
      );

      return result != null ? Contact.fromJson(_safeMapCast(result)) : null;
    } on PlatformException catch (e) {
      throw Exception('Failed to get contact: ${e.message}');
    }
  }

  @override
  Future<List<Contact>> searchContacts(
    String query, {
    bool withProperties = false,
    bool sorted = true,
  }) async {
    try {
      final result = await methodChannel.invokeMethod<List<dynamic>>(
        'searchContacts',
        {
          'query': query,
          'withProperties': withProperties,
          'sorted': sorted,
        },
      );

      return result
              ?.map<Contact>(
                (dynamic item) => Contact.fromJson(_safeMapCast(item)),
              )
              .toList() ??
          <Contact>[];
    } on PlatformException catch (e) {
      throw Exception('Failed to search contacts: ${e.message}');
    }
  }

  @override
  Future<Contact> createContact(Contact contact) async {
    try {
      final result = await methodChannel.invokeMethod<dynamic>(
        'createContact',
        contact.toJson(),
      );

      return Contact.fromJson(_safeMapCast(result));
    } on PlatformException catch (e) {
      throw Exception('Failed to create contact: ${e.message}');
    }
  }

  @override
  Future<Contact> updateContact(Contact contact) async {
    try {
      final result = await methodChannel.invokeMethod<dynamic>(
        'updateContact',
        contact.toJson(),
      );

      return Contact.fromJson(_safeMapCast(result));
    } on PlatformException catch (e) {
      throw Exception('Failed to update contact: ${e.message}');
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    try {
      await methodChannel.invokeMethod('deleteContact', {'id': id});
    } on PlatformException catch (e) {
      throw Exception('Failed to delete contact: ${e.message}');
    }
  }

  @override
  Stream<List<Contact>> observeContacts() {
    return eventChannel.receiveBroadcastStream().map(
      (event) => (event as List)
          .map<Contact>((dynamic item) => Contact.fromJson(_safeMapCast(item)))
          .toList(),
    );
  }

  // Helper methods for parsing data

  /// Safely converts a dynamic object to `Map<String, dynamic>`
  /// Handles nested maps and lists that come from platform channels
  Map<String, dynamic> _safeMapCast(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map<Object?, Object?>) {
      return _convertToStringDynamicMap(data);
    } else if (data is Map) {
      // Handle other Map types by converting to Map<Object?, Object?> first
      final objectMap = <Object?, Object?>{};
      data.forEach((key, value) {
        objectMap[key] = value;
      });
      return _convertToStringDynamicMap(objectMap);
    } else {
      throw ArgumentError('Expected Map but got ${data.runtimeType}');
    }
  }

  /// Recursively converts `Map<Object?, Object?>` to `Map<String, dynamic>`
  /// This handles nested maps and lists that come from platform channels
  Map<String, dynamic> _convertToStringDynamicMap(
    Map<Object?, Object?> source,
  ) {
    final result = <String, dynamic>{};

    for (final entry in source.entries) {
      final key = entry.key?.toString() ?? '';
      final value = entry.value;

      if (value is Map<Object?, Object?>) {
        result[key] = _convertToStringDynamicMap(value);
      } else if (value is Map) {
        // Handle other Map types
        final objectMap = <Object?, Object?>{};
        value.forEach((k, v) {
          objectMap[k] = v;
        });
        result[key] = _convertToStringDynamicMap(objectMap);
      } else if (value is List) {
        result[key] = _convertListToDynamic(value);
      } else {
        result[key] = value;
      }
    }

    return result;
  }

  /// Recursively converts List elements that may contain nested maps
  List<dynamic> _convertListToDynamic(List<dynamic> source) {
    return source.map((item) {
      if (item is Map<Object?, Object?>) {
        return _convertToStringDynamicMap(item);
      } else if (item is Map) {
        // Handle other Map types
        final objectMap = <Object?, Object?>{};
        item.forEach((k, v) {
          objectMap[k] = v;
        });
        return _convertToStringDynamicMap(objectMap);
      } else if (item is List) {
        return _convertListToDynamic(item);
      } else {
        return item;
      }
    }).toList();
  }

  PermissionStatus _parsePermissionStatus(String? status) {
    switch (status) {
      case 'notDetermined':
        return PermissionStatus.notDetermined;
      case 'denied':
        return PermissionStatus.denied;
      case 'authorized':
      case 'granted':
        return PermissionStatus.authorized;
      case 'limited':
        return PermissionStatus.limited;
      case 'restricted':
        return PermissionStatus.restricted;
      default:
        return PermissionStatus.notDetermined;
    }
  }
}
