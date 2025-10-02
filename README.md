# Contacts Bridge

A modern Flutter plugin for managing device contacts with comprehensive support for Android, iOS, and macOS. Built with clean architecture principles and providing a type-safe API for all contact operations.

[![pub package](https://img.shields.io/pub/v/calendar_bridge.svg)](https://pub.dev/packages/calendar_bridge)
[![Platform](https://img.shields.io/badge/platform-android%20%7C%20ios%20%7C%20macos-lightgrey)](https://pub.dev/packages/calendar_bridge)

## Table of Contents

- [Features](#features)
- [Platform Support](#platform-support)
- [Installation](#installation)
- [Platform Setup](#platform-setup)
- [Usage](#usage)
  - [Basic Setup](#basic-setup)
  - [Permission Handling](#permission-handling)
  - [Working with Contacts](#working-with-contacts)
  - [Creating and Updating Contacts](#creating-and-updating-contacts)
  - [Searching Contacts](#searching-contacts)
  - [Contact Picker](#contact-picker)
- [Error Handling](#error-handling)
- [Models](#models)
- [Example App](#example-app)
- [Testing](#testing)
- [Architecture](#architecture)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## Features

✅ **Complete Contact Management**
- Get all contacts with optional properties
- Get individual contacts by ID
- Create new contacts
- Update existing contacts
- Delete contacts
- Search contacts by name, phone, or email

✅ **Rich Contact Information**
- Names (first, middle, last, nickname, etc.)
- Phone numbers with labels
- Email addresses with labels
- Physical addresses
- Organizations and job titles
- Notes and websites
- Social profiles
- Events (birthdays, anniversaries)
- Contact photos and thumbnails

✅ **Advanced Features**
- Contact groups and accounts
- Starred/favorite contacts
- Linked contacts
- Contact change observation
- Native contact picker
- Read-only and write permissions

✅ **Clean Architecture**
- Type-safe Result pattern for error handling
- Reactive programming with streams
- Dependency injection ready
- Well-documented API
- Comprehensive error types

## Platform Support

| Platform | Minimum Version | Status |
|----------|-----------------|--------|
| Android  | API 21 (5.0)    | ✅ Full Support |
| iOS      | 12.0            | ✅ Full Support |
| macOS    | 10.14           | ✅ Full Support |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  contacts_bridge: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_CONTACTS" />
```

For read-only access, you only need:

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to contacts to manage your address book.</string>
```

### macOS

Add the following to your `macos/Runner/Info.plist`:

```xml
<key>NSContactsUsageDescription</key>
<string>This app needs access to contacts to manage your address book.</string>
```

Also, add the contacts entitlement to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.personal-information.addressbook</key>
<true/>
```

## Usage

### Basic Setup

```dart
import 'package:contacts_bridge/contacts_bridge.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _contactsBridge = ContactsBridge();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContactsScreen(),
    );
  }
}
```

### Permission Handling

Always check and request permissions before accessing contacts:

```dart
class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _contactsBridge = ContactsBridge();
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Check current permission status
    final statusResult = await _contactsBridge.getPermissionStatus();
    
    statusResult
      .onSuccess((status) {
        if (!status.canRead) {
          _requestPermission();
        } else {
          _loadContacts();
        }
      })
      .onFailure((failure) {
        print('Permission check failed: ${failure.message}');
      });
  }

  Future<void> _requestPermission() async {
    final result = await _contactsBridge.requestPermission(
      readOnly: false, // Set to true for read-only access
    );
    
    result
      .onSuccess((status) {
        if (status.canRead) {
          _loadContacts();
        } else {
          _showPermissionDeniedDialog();
        }
      })
      .onFailure((failure) {
        print('Permission request failed: ${failure.message}');
      });
  }
}
```

### Working with Contacts

#### Getting All Contacts

```dart
Future<void> _loadContacts() async {
  final result = await _contactsBridge.getAllContacts(
    withProperties: true,  // Include detailed properties
    withThumbnail: true,   // Include low-res thumbnails
    withPhoto: false,      // Exclude high-res photos for performance
    sorted: true,          // Sort by display name
  );

  result
    .onSuccess((contacts) {
      setState(() {
        _contacts = contacts;
      });
      print('Loaded ${contacts.length} contacts');
    })
    .onFailure((failure) {
      print('Failed to load contacts: ${failure.message}');
    });
}
```

#### Getting a Single Contact

```dart
Future<void> _getContact(String contactId) async {
  final result = await _contactsBridge.getContact(
    contactId,
    withProperties: true,
    withThumbnail: true,
    withPhoto: true,
  );

  result
    .onSuccess((contact) {
      if (contact != null) {
        print('Contact: ${contact.displayName}');
        print('Phones: ${contact.phones.map((p) => p.number).join(', ')}');
        print('Emails: ${contact.emails.map((e) => e.address).join(', ')}');
      }
    })
    .onFailure((failure) {
      print('Failed to get contact: ${failure.message}');
    });
}
```

### Creating and Updating Contacts

#### Creating a New Contact

```dart
Future<void> _createContact() async {
  final newContact = Contact(
    id: '', // Empty for new contacts
    displayName: 'John Doe',
    name: ContactName(
      first: 'John',
      last: 'Doe',
      middle: 'William',
    ),
    phones: [
      ContactPhone(
        number: '+1234567890',
        label: 'mobile',
      ),
    ],
    emails: [
      ContactEmail(
        address: 'john.doe@example.com',
        label: 'work',
      ),
    ],
    addresses: [
      ContactAddress(
        street: '123 Main St',
        city: 'Anytown',
        state: 'CA',
        postalCode: '12345',
        country: 'USA',
        label: 'home',
      ),
    ],
    organizations: [
      ContactOrganization(
        name: 'Example Corp',
        title: 'Software Engineer',
      ),
    ],
    notes: ['Important client contact'],
    websites: ['https://johndoe.com'],
  );

  final result = await _contactsBridge.createContact(newContact);
  
  result
    .onSuccess((createdContact) {
      print('Contact created with ID: ${createdContact.id}');
    })
    .onFailure((failure) {
      print('Failed to create contact: ${failure.message}');
    });
}
```

#### Updating an Existing Contact

```dart
Future<void> _updateContact(Contact contact) async {
  final updatedContact = contact.copyWith(
    displayName: 'John Updated Doe',
    phones: [
      ...contact.phones,
      ContactPhone(number: '+0987654321', label: 'home'),
    ],
  );

  final result = await _contactsBridge.updateContact(updatedContact);
  
  result
    .onSuccess((contact) {
      print('Contact updated: ${contact.displayName}');
    })
    .onFailure((failure) {
      print('Failed to update contact: ${failure.message}');
    });
}
```

#### Deleting a Contact

```dart
Future<void> _deleteContact(String contactId) async {
  final result = await _contactsBridge.deleteContact(contactId);
  
  result
    .onSuccess((_) {
      print('Contact deleted successfully');
    })
    .onFailure((failure) {
      print('Failed to delete contact: ${failure.message}');
    });
}
```

### Searching Contacts

```dart
Future<void> _searchContacts(String query) async {
  final result = await _contactsBridge.searchContacts(
    query,
    withProperties: true,
    sorted: true,
  );

  result
    .onSuccess((contacts) {
      print('Found ${contacts.length} contacts matching "$query"');
      for (final contact in contacts) {
        print('- ${contact.displayName}');
      }
    })
    .onFailure((failure) {
      print('Search failed: ${failure.message}');
    });
}
```

### Contact Picker

Use the native contact picker to let users select a contact:

```dart
Future<void> _pickContact() async {
  final result = await _contactsBridge.pickContact();
  
  result
    .onSuccess((contact) {
      if (contact != null) {
        print('Selected contact: ${contact.displayName}');
      } else {
        print('No contact selected');
      }
    })
    .onFailure((failure) {
      print('Contact picker failed: ${failure.message}');
    });
}
```

### Observing Contact Changes

Listen to contact changes in real-time:

```dart
StreamSubscription<List<Contact>>? _contactsSubscription;

void _startListening() {
  _contactsSubscription = _contactsBridge.observeContacts().listen(
    (contacts) {
      setState(() {
        _contacts = contacts;
      });
      print('Contacts updated: ${contacts.length} total');
    },
    onError: (error) {
      print('Contact observation error: $error');
    },
  );
}

@override
void dispose() {
  _contactsSubscription?.cancel();
  super.dispose();
}
```

## Error Handling

The plugin uses a `Result<T>` pattern for comprehensive error handling:

```dart
// Handle success and failure cases
result
  .onSuccess((data) {
    // Handle successful result
  })
  .onFailure((failure) {
    // Handle different error types
    switch (failure.runtimeType) {
      case PermissionFailure:
        print('Permission denied: ${failure.message}');
        break;
      case NetworkFailure:
        print('Network error: ${failure.message}');
        break;
      case ValidationFailure:
        print('Validation error: ${failure.message}');
        break;
      default:
        print('Unknown error: ${failure.message}');
    }
  });

// Or check directly
if (result.isSuccess) {
  final data = result.data;
  // Use data
} else {
  final failure = result.failure;
  // Handle error
}
```

### Common Error Types

- `PermissionFailure`: Contacts permission not granted
- `ValidationFailure`: Invalid contact data
- `NetworkFailure`: Platform-specific errors
- `ServerFailure`: Unexpected system errors

## Models

### Contact

The main contact model with comprehensive information:

```dart
class Contact {
  final String id;
  final String displayName;
  final ContactName name;
  final List<ContactPhone> phones;
  final List<ContactEmail> emails;
  final List<ContactAddress> addresses;
  final List<ContactOrganization> organizations;
  final List<String> notes;
  final List<String> websites;
  final List<String> socialProfiles;
  final List<ContactEvent> events;
  final List<String> groups;
  final List<String> accounts;
  final Uint8List? thumbnail;
  final Uint8List? photo;
  final bool isStarred;
  final List<String> linkedContactIds;
  final bool propertiesFetched;
  final bool thumbnailFetched;
  final bool photoFetched;
}
```

### ContactName

```dart
class ContactName {
  final String first;
  final String middle;
  final String last;
  final String prefix;
  final String suffix;
  final String nickname;
  final String phoneticFirst;
  final String phoneticMiddle;
  final String phoneticLast;
}
```

### ContactPhone

```dart
class ContactPhone {
  final String number;
  final String label;
  final bool isPrimary;
}
```

### ContactEmail

```dart
class ContactEmail {
  final String address;
  final String label;
  final bool isPrimary;
}
```

### ContactAddress

```dart
class ContactAddress {
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String label;
  final bool isPrimary;
}
```

### PermissionStatus

```dart
enum PermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
}

extension PermissionStatusExtension on PermissionStatus {
  bool get canRead;
  bool get canWrite;
  String get description;
}
```

## Example App

The plugin includes a comprehensive example app demonstrating all features:

```bash
cd example
flutter run
```

The example app shows:
- Permission handling
- Loading and displaying contacts
- Search functionality  
- Creating new contacts
- Updating existing contacts
- Contact deletion
- Native contact picker
- Error handling patterns

## Testing

### Running Tests

```bash
# Run unit tests
flutter test

# Run integration tests
cd example
flutter test integration_test/
```

### Testing Strategies

The plugin includes:
- Unit tests for business logic
- Integration tests for platform channels
- Example app for manual testing
- Mock implementations for testing

## Architecture

The plugin follows Clean Architecture principles:

```
lib/
├── plugin/                 # Plugin facade and platform interface
├── src/
│   ├── core/              # Core utilities and error handling
│   ├── data/              # Data layer with repositories
│   └── domain/            # Domain layer with entities and use cases
└── contacts_bridge.dart   # Main export file
```

### Key Architectural Decisions

- **Result Pattern**: Type-safe error handling without exceptions
- **Repository Pattern**: Abstract data access with platform implementations
- **Use Cases**: Encapsulate business logic
- **Entities**: Pure Dart models with no platform dependencies
- **Dependency Injection**: Ready for DI frameworks

## Contributing

We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) before submitting PRs.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/contacts_bridge.git`
3. Create a branch: `git checkout -b feature/your-feature`
4. Make changes and add tests
5. Run tests: `flutter test`
6. Submit a Pull Request

### Code Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Add documentation for public APIs
- Include tests for new features
- Use conventional commit messages

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [GitHub Wiki](https://github.com/ahmtydn/contacts_bridge/wiki)
- **Issues**: [GitHub Issues](https://github.com/ahmtydn/contacts_bridge/issues)
- **Discussions**: [GitHub Discussions](https://github.com/ahmtydn/contacts_bridge/discussions)
- **Email**: ahmtydn@gmail.com

### Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and versions.

---

Made with ❤️ by [Ahmet Aydin](https://github.com/ahmtydn)
