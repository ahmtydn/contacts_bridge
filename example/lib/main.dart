import 'package:contacts_bridge/contacts_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'contact_detail_page.dart';
import 'contact_form_page.dart';

void main() {
  runApp(const ContactsBridgeApp());
}

class ContactsBridgeApp extends StatelessWidget {
  const ContactsBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts Bridge Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ContactsHomePage(),
      routes: {
        '/contact_detail': (context) => const ContactDetailPage(),
        '/contact_form': (context) => const ContactFormPage(),
      },
    );
  }
}

class ContactsHomePage extends StatefulWidget {
  const ContactsHomePage({super.key});

  @override
  State<ContactsHomePage> createState() => _ContactsHomePageState();
}

class _ContactsHomePageState extends State<ContactsHomePage> {
  final _contactsBridge = ContactsBridge();
  String _platformVersion = 'Unknown';
  String _permissionStatus = 'Unknown';
  List<Contact> _contacts = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _getPlatformVersion();
    await _checkPermissionStatus();
  }

  Future<void> _getPlatformVersion() async {
    try {
      final version = await _contactsBridge.getPlatformVersion() ?? 'Unknown';
      setState(() {
        _platformVersion = version;
      });
    } on PlatformException {
      setState(() {
        _platformVersion = 'Failed to get platform version';
      });
    }
  }

  Future<void> _checkPermissionStatus() async {
    final result = await _contactsBridge.getPermissionStatus();
    result
        .onSuccess((status) {
          setState(() {
            _permissionStatus = status.name;
          });
        })
        .onFailure((failure) {
          setState(() {
            _permissionStatus = 'Error: ${failure.message}';
          });
        });
  }

  Future<void> _requestPermission() async {
    final result = await _contactsBridge.requestPermission();

    result
        .onSuccess((status) {
          setState(() {
            _permissionStatus = status.description;
          });
          _showSnackBar('Permission: ${status.description}', Colors.green);
          if (status.canRead) {
            _loadAllContacts();
          }
        })
        .onFailure((failure) {
          _showSnackBar('Permission failed: ${failure.message}', Colors.red);
        });
  }

  Future<void> _loadAllContacts() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _contactsBridge.getAllContacts(
      withProperties: true,
      withThumbnail: true,
      sorted: true,
    );

    result
        .onSuccess((contacts) {
          setState(() {
            _contacts = contacts;
            _isLoading = false;
          });
          _showSnackBar('Loaded ${contacts.length} contacts', Colors.green);
        })
        .onFailure((failure) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar(
            'Failed to load contacts: ${failure.message}',
            Colors.red,
          );
        });
  }

  Future<void> _searchContacts(String query) async {
    if (query.isEmpty) {
      _loadAllContacts();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _contactsBridge.searchContacts(
      query,
      withProperties: true,
      sorted: true,
    );

    result
        .onSuccess((contacts) {
          setState(() {
            _contacts = contacts;
            _isLoading = false;
          });
        })
        .onFailure((failure) {
          setState(() {
            _isLoading = false;
          });

          _showSnackBar('Search failed: ${failure.message}', Colors.red);
        });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts Bridge Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllContacts,
            tooltip: 'Refresh Contacts',
          ),
        ],
      ),
      body: Column(
        children: [
          // Platform and Permission Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Platform: $_platformVersion'),
                Text('Permission: $_permissionStatus'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: const Text('Request Permission'),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadAllContacts();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _searchContacts(value);
                  }
                });
              },
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _loadAllContacts,
                    icon: const Icon(Icons.people),
                    label: const Text('Load All'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/contact_form');
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Create'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Contacts List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contacts.isEmpty
                ? const Center(
                    child: Text(
                      'No contacts found.\nTap "Load All" to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return ContactListTile(
                        contact: contact,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/contact_detail',
                            arguments: contact.id,
                          );
                        },
                        onEdit: () {
                          Navigator.pushNamed(
                            context,
                            '/contact_form',
                            arguments: contact.id,
                          );
                        },
                        onDelete: () => _deleteContact(contact),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteContact(Contact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text(
          'Are you sure you want to delete ${contact.displayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _contactsBridge.deleteContact(contact.id);
      result
          .onSuccess((_) {
            _showSnackBar('Contact deleted', Colors.green);
            _loadAllContacts();
          })
          .onFailure((failure) {
            _showSnackBar('Delete failed: ${failure.message}', Colors.red);
          });
    }
  }
}

// Contact List Tile Widget
class ContactListTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = contact.displayName;
    final phones = contact.phones;
    final firstPhone = phones.isNotEmpty ? phones.first.number : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: firstPhone.isNotEmpty ? Text(firstPhone) : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
