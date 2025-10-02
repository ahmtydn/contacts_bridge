import 'package:contacts_bridge/contacts_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Unified Contact Form Page for both creating and editing contacts
class ContactFormPage extends StatefulWidget {
  const ContactFormPage({super.key});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  Contact? _originalContact;
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _isLoading = false;
  String? _error;
  final _contactsBridge = ContactsBridge();

  // Determine if this is edit mode or create mode
  bool get _isEditMode => _originalContact != null;
  String get _pageTitle => _isEditMode ? 'Edit Contact' : 'Create Contact';
  String get _saveButtonText => _isEditMode ? 'Update' : 'Create';

  // Form controllers
  final _displayNameController = TextEditingController();
  final _givenNameController = TextEditingController();
  final _familyNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _nickNameController = TextEditingController();
  final _notesController = TextEditingController();

  // Dynamic lists
  List<ContactPhone> _phones = [];
  List<ContactEmail> _emails = [];
  List<ContactAddress> _addresses = [];
  List<ContactOrganization> _organizations = [];
  List<ContactEvent> _events = [];
  List<String> _websites = [];

  // Controllers for dynamic fields
  final List<TextEditingController> _phoneControllers = [];
  final List<TextEditingController> _emailControllers = [];
  final List<TextEditingController> _websiteControllers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is String && _originalContact == null) {
      // Edit mode - load contact by ID
      _loadContact(arguments);
    } else if (arguments == null && !_isLoading && _originalContact == null) {
      // Create mode - initialize empty form
      _initializeEmptyForm();
    }
  }

  Future<void> _loadContact(String contactId) async {
    setState(() {
      _isLoading = true;
    });

    final result = await _contactsBridge.getContact(
      contactId,
      withProperties: true,
      withThumbnail: true,
      withPhoto: true,
    );

    if (mounted) {
      setState(() {
        if (result.isSuccess) {
          _originalContact = result.value;
          _error = null;
          _initializeForm();
        } else {
          _error = result.failure?.message ?? 'Failed to load contact';
        }
        _isLoading = false;
      });
    }
  }

  void _initializeEmptyForm() {
    // Initialize with empty values for create mode
    _phones = [];
    _emails = [];
    _addresses = [];
    _organizations = [];
    _events = [];
    _websites = [];

    // Add at least one phone and email field for convenience
    _addPhone();
    _addEmail();
  }

  void _initializeForm() {
    if (_originalContact == null) return;

    // Initialize basic fields
    _displayNameController.text = _originalContact!.displayName;
    _givenNameController.text = _originalContact!.name.first;
    _familyNameController.text = _originalContact!.name.last;
    _middleNameController.text = _originalContact!.name.middle;
    _nickNameController.text = _originalContact!.name.nickname;
    _notesController.text = _originalContact!.notes.join('\n');

    // Initialize dynamic lists
    _phones = List.from(_originalContact!.phones);
    _emails = List.from(_originalContact!.emails);
    _addresses = List.from(_originalContact!.addresses);
    _organizations = List.from(_originalContact!.organizations);
    _events = List.from(_originalContact!.events);
    _websites = List.from(_originalContact!.websites);

    // Initialize controllers for dynamic fields
    _initializeDynamicControllers();
  }

  void _initializeDynamicControllers() {
    _initializePhoneControllers();
    _initializeEmailControllers();
    _initializeWebsiteControllers();
  }

  void _initializePhoneControllers() {
    _phoneControllers.clear();
    for (final phone in _phones) {
      _phoneControllers.add(TextEditingController(text: phone.number));
    }
  }

  void _initializeEmailControllers() {
    _emailControllers.clear();
    for (final email in _emails) {
      _emailControllers.add(TextEditingController(text: email.address));
    }
  }

  void _initializeWebsiteControllers() {
    _websiteControllers.clear();
    for (final website in _websites) {
      _websiteControllers.add(TextEditingController(text: website));
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _displayNameController.dispose();
    _givenNameController.dispose();
    _familyNameController.dispose();
    _middleNameController.dispose();
    _nickNameController.dispose();
    _notesController.dispose();

    for (final controller in _phoneControllers) {
      controller.dispose();
    }
    for (final controller in _emailControllers) {
      controller.dispose();
    }
    for (final controller in _websiteControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Update phone numbers from controllers
      for (int i = 0; i < _phones.length; i++) {
        _phones[i] = _phones[i].copyWith(number: _phoneControllers[i].text);
      }

      // Update email addresses from controllers
      for (int i = 0; i < _emails.length; i++) {
        _emails[i] = _emails[i].copyWith(address: _emailControllers[i].text);
      }

      // Update websites from controllers
      for (int i = 0; i < _websites.length; i++) {
        _websites[i] = _websiteControllers[i].text;
      }

      // Create contact object
      final contact = _isEditMode
          ? _originalContact!.copyWith(
              displayName: _displayNameController.text,
              name: ContactName(
                first: _givenNameController.text,
                last: _familyNameController.text,
                middle: _middleNameController.text,
                nickname: _nickNameController.text,
              ),
              phones: _phones,
              emails: _emails,
              addresses: _addresses,
              organizations: _organizations,
              events: _events,
              websites: _websites,
              notes: _notesController.text
                  .split('\n')
                  .where((note) => note.trim().isNotEmpty)
                  .toList(),
            )
          : Contact(
              id: '', // Will be generated by the system
              displayName: _displayNameController.text.isNotEmpty
                  ? _displayNameController.text
                  : '${_givenNameController.text} ${_familyNameController.text}'
                        .trim(),
              name: ContactName(
                first: _givenNameController.text,
                last: _familyNameController.text,
                middle: _middleNameController.text,
                nickname: _nickNameController.text,
              ),
              phones: _phones,
              emails: _emails,
              addresses: _addresses,
              organizations: _organizations,
              events: _events,
              websites: _websites,
              notes: _notesController.text
                  .split('\n')
                  .where((note) => note.trim().isNotEmpty)
                  .toList(),
            );

      // Save contact
      final result = _isEditMode
          ? await _contactsBridge.updateContact(contact)
          : await _contactsBridge.createContact(contact);

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode
                    ? 'Contact updated successfully!'
                    : 'Contact created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, result.value);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_isEditMode ? 'Update' : 'Create'} failed: ${result.failure?.message ?? "Unknown error"}',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to ${_isEditMode ? 'update' : 'create'} contact: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : _saveContact,
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_saveButtonText),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information'),
              _buildTextField(
                controller: _displayNameController,
                label: 'Display Name',
                icon: Icons.person,
                validator: !_isEditMode
                    ? (value) {
                        if ((value == null || value.isEmpty) &&
                            _givenNameController.text.isEmpty &&
                            _familyNameController.text.isEmpty) {
                          return 'Display name or first/last name is required';
                        }
                        return null;
                      }
                    : null,
              ),
              _buildTextField(
                controller: _givenNameController,
                label: 'First Name',
                icon: Icons.person_outline,
                validator: !_isEditMode
                    ? (value) {
                        if ((value == null || value.isEmpty) &&
                            _familyNameController.text.isEmpty &&
                            _displayNameController.text.isEmpty) {
                          return 'First name is required when no display name is provided';
                        }
                        return null;
                      }
                    : null,
              ),
              _buildTextField(
                controller: _familyNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
              ),
              _buildTextField(
                controller: _middleNameController,
                label: 'Middle Name',
                icon: Icons.person_outline,
              ),
              _buildTextField(
                controller: _nickNameController,
                label: 'Nickname',
                icon: Icons.face,
              ),

              const SizedBox(height: 24),

              // Phone Numbers Section
              _buildSectionHeader('Phone Numbers'),
              ..._buildPhoneFields(),
              _buildAddButton('Add Phone', Icons.phone, _addPhone),

              const SizedBox(height: 24),

              // Email Addresses Section
              _buildSectionHeader('Email Addresses'),
              ..._buildEmailFields(),
              _buildAddButton('Add Email', Icons.email, _addEmail),

              const SizedBox(height: 24),

              // Websites Section
              _buildSectionHeader('Websites'),
              ..._buildWebsiteFields(),
              _buildAddButton('Add Website', Icons.web, _addWebsite),

              const SizedBox(height: 24),

              // Events Section
              _buildSectionHeader('Events'),
              ..._buildEventFields(),
              _buildAddButton('Add Event', Icons.event, _addEvent),

              const SizedBox(height: 24),

              // Notes Section
              _buildSectionHeader('Notes'),
              _buildTextField(
                controller: _notesController,
                label: 'Notes',
                icon: Icons.note,
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Save Button (alternative to app bar button)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _saveContact,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text('${_isEditMode ? 'Updating' : 'Creating'}...'),
                          ],
                        )
                      : Text('$_saveButtonText Contact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  List<Widget> _buildPhoneFields() {
    return List.generate(_phones.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _phoneControllers[index],
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: '${_phones[index].label.name.toUpperCase()} Phone',
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 3) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removePhone(index),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildEmailFields() {
    return List.generate(_emails.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailControllers[index],
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: '${_emails[index].label.name.toUpperCase()} Email',
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeEmail(index),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildWebsiteFields() {
    return List.generate(_websites.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _websiteControllers[index],
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  prefixIcon: Icon(Icons.web),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Enter a valid website URL';
                    }
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeWebsite(index),
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildEventFields() {
    return List.generate(_events.length, (index) {
      final event = _events[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.displayLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${event.month}/${event.day}${event.year != null ? '/${event.year}' : ''}',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeEvent(index),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildAddButton(String text, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
      ),
    );
  }

  void _addPhone() {
    setState(() {
      _phones.add(const ContactPhone(number: '', label: PhoneLabel.mobile));
      _phoneControllers.add(TextEditingController());
    });
  }

  void _removePhone(int index) {
    setState(() {
      _phones.removeAt(index);
      _phoneControllers[index].dispose();
      _phoneControllers.removeAt(index);
    });
  }

  void _addEmail() {
    setState(() {
      _emails.add(const ContactEmail(address: '', label: EmailLabel.home));
      _emailControllers.add(TextEditingController());
    });
  }

  void _removeEmail(int index) {
    setState(() {
      _emails.removeAt(index);
      _emailControllers[index].dispose();
      _emailControllers.removeAt(index);
    });
  }

  void _addWebsite() {
    setState(() {
      _websites.add('');
      _websiteControllers.add(TextEditingController());
    });
  }

  void _removeWebsite(int index) {
    setState(() {
      _websites.removeAt(index);
      _websiteControllers[index].dispose();
      _websiteControllers.removeAt(index);
    });
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) => _EventDialog(
        onEventAdded: (event) {
          setState(() {
            _events.add(event);
          });
        },
      ),
    );
  }

  void _removeEvent(int index) {
    setState(() {
      _events.removeAt(index);
    });
  }
}

class _EventDialog extends StatefulWidget {
  final Function(ContactEvent) onEventAdded;

  const _EventDialog({required this.onEventAdded});

  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  EventLabel _selectedLabel = EventLabel.birthday;
  int _selectedMonth = DateTime.now().month;
  int _selectedDay = DateTime.now().day;
  int? _selectedYear;
  final _customLabelController = TextEditingController();

  @override
  void dispose() {
    _customLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<EventLabel>(
            initialValue: _selectedLabel,
            decoration: const InputDecoration(
              labelText: 'Event Type',
              border: OutlineInputBorder(),
            ),
            items: EventLabel.values.map((label) {
              return DropdownMenuItem(
                value: label,
                child: Text(label.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLabel = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          if (_selectedLabel == EventLabel.custom)
            TextFormField(
              controller: _customLabelController,
              decoration: const InputDecoration(
                labelText: 'Custom Label',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedMonth,
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem(
                      value: month,
                      child: Text(month.toString()),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Day',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(31, (index) {
                    final day = index + 1;
                    return DropdownMenuItem(
                      value: day,
                      child: Text(day.toString()),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _selectedDay = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Year (Optional)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              _selectedYear = value.isEmpty ? null : int.tryParse(value);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final event = ContactEvent(
              month: _selectedMonth,
              day: _selectedDay,
              year: _selectedYear,
              label: _selectedLabel,
              customLabel: _customLabelController.text,
            );
            widget.onEventAdded(event);
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
