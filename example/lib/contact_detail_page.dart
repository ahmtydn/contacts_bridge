import 'package:contacts_bridge/contacts_bridge.dart';
import 'package:flutter/material.dart';

// Contact Detail Page
class ContactDetailPage extends StatefulWidget {
  const ContactDetailPage({super.key});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  Contact? contact;
  bool isLoading = true;
  String? error;
  final _contactsBridge = ContactsBridge();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadContact();
  }

  Future<void> _loadContact() async {
    final contactId = ModalRoute.of(context)!.settings.arguments as String;

    final result = await _contactsBridge.getContact(
      contactId,
      withProperties: true,
      withThumbnail: true,
      withPhoto: true,
    );

    if (mounted) {
      setState(() {
        if (result.isSuccess) {
          contact = result.value;
          error = null;
        } else {
          error = result.failure?.message ?? 'Failed to load contact';
        }
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || contact == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(error ?? 'Contact not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final displayName = contact!.displayName;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/contact_form',
                arguments: contact!.id,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Contact Details
            _buildInfoSection('Basic Information', [
              _buildInfoRow('ID', contact!.id),
              _buildInfoRow('Display Name', contact!.displayName),
              _buildInfoRow('Starred', contact!.isStarred.toString()),
            ]),

            // Name Details
            if (contact!.name.first.isNotEmpty ||
                contact!.name.last.isNotEmpty ||
                contact!.name.middle.isNotEmpty ||
                contact!.name.prefix.isNotEmpty ||
                contact!.name.suffix.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildInfoSection('Name Details', [
                _buildInfoRow('Given Name', contact!.name.first),
                _buildInfoRow('Family Name', contact!.name.last),
                _buildInfoRow('Middle Name', contact!.name.middle),
                _buildInfoRow('Prefix', contact!.name.prefix),
                _buildInfoRow('Suffix', contact!.name.suffix),
              ]),
            ],
            // Phone Numbers
            if (contact!.phones.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListSection<ContactPhone>(
                'Phone Numbers',
                contact!.phones,
                (phone) => '${phone.displayLabel}: ${phone.number}',
              ),
            ],

            // Email Addresses
            if (contact!.emails.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListSection<ContactEmail>(
                'Email Addresses',
                contact!.emails,
                (email) => '${email.displayLabel}: ${email.address}',
              ),
            ],

            // Addresses
            if (contact!.addresses.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListSection<ContactAddress>(
                'Addresses',
                contact!.addresses,
                (address) =>
                    '${address.displayLabel}: ${address.formattedAddress}',
              ),
            ],

            // Organizations
            if (contact!.organizations.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListSection<ContactOrganization>(
                'Organizations',
                contact!.organizations,
                (org) => org.formattedInfo.isNotEmpty
                    ? org.formattedInfo
                    : '${org.company} - ${org.title}',
              ),
            ],

            // Websites
            if (contact!.websites.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListSection<String>(
                'Websites',
                contact!.websites,
                (website) => website,
              ),
            ],

            // Events
            if (contact!.events.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListSection<ContactEvent>('Events', contact!.events, (
                event,
              ) {
                final year = event.year != null ? '${event.year}-' : '';
                final month = event.month.toString().padLeft(2, '0');
                final day = event.day.toString().padLeft(2, '0');
                return '${event.displayLabel}: $year$month-$day';
              }),
            ],

            // Notes
            if (contact!.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildListSection<String>(
                'Notes',
                contact!.notes,
                (note) => note,
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListSection<T>(
    String title,
    List<T> items,
    String Function(T) itemBuilder,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• ${itemBuilder(item)}'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
