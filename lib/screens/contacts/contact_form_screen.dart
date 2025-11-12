import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mycashbook2/l10n/app_localizations.dart';
import '../../providers/contact_provider.dart';
import '../../database/models/contact.dart';

class ContactFormScreen extends StatefulWidget {
  final String? contactId;
  const ContactFormScreen({super.key, this.contactId});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  Contact? _existingContact;

  @override
  void initState() {
    super.initState();
    if (widget.contactId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadContact();
      });
    }
  }

  Future<void> _loadContact() async {
    final contactProvider = context.read<ContactProvider>();
    await contactProvider.loadContacts();
    final contact = contactProvider.getContactById(int.parse(widget.contactId!));
    if (contact != null) {
      setState(() {
        _existingContact = contact;
        _nameController.text = contact.name;
        _phoneController.text = contact.phone ?? '';
        _emailController.text = contact.email ?? '';
      });
    }
  }

  Future<void> _importFromDevice() async {
    try {
      // Request permission
      final permission = await Permission.contacts.request();
      if (!permission.isGranted) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.contactPermissionRequired,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
        return;
      }

      // Load contacts
      final contacts = await flutter_contacts.FlutterContacts.getContacts(
        withProperties: true,
      );

      if (contacts.isEmpty) {
        if (mounted) {
          Fluttertoast.showToast(
            msg: AppLocalizations.of(context)!.noContactsFoundOnDevice,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
        return;
      }

      // Show contact selection dialog
      final selectedContact = await showDialog<flutter_contacts.Contact>(
        context: context,
        builder: (context) => _ContactSelectionDialog(contacts: contacts),
      );

      if (selectedContact != null) {
        setState(() {
          _nameController.text = selectedContact.displayName;
          _phoneController.text = selectedContact.phones.isNotEmpty
              ? selectedContact.phones.first.number
              : '';
          _emailController.text = selectedContact.emails.isNotEmpty
              ? selectedContact.emails.first.address
              : '';
        });
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.errorImportingContact(e.toString()),
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now().toIso8601String();
      final contact = Contact(
        id: _existingContact?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        createdAt: _existingContact?.createdAt ?? now,
      );

      if (_existingContact == null) {
        await context.read<ContactProvider>().addContact(contact);
      } else {
        await context.read<ContactProvider>().updateContact(contact);
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Fluttertoast.showToast(
          msg: _existingContact == null
              ? l10n.contactCreated
              : l10n.contactUpdated,
          toastLength: Toast.LENGTH_SHORT,
        );
        context.go('/contacts');
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: AppLocalizations.of(context)!.error(e.toString()),
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.go('/contacts');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_existingContact == null 
              ? AppLocalizations.of(context)!.newContact 
              : AppLocalizations.of(context)!.editContact),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/contacts'),
          ),
        ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phoneOptional,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.emailOptional,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _importFromDevice,
              icon: const Icon(Icons.contacts),
              label: Text(AppLocalizations.of(context)!.importFromDevice),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveContact,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(AppLocalizations.of(context)!.saveContact),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _ContactSelectionDialog extends StatefulWidget {
  final List<flutter_contacts.Contact> contacts;

  const _ContactSelectionDialog({required this.contacts});

  @override
  State<_ContactSelectionDialog> createState() => _ContactSelectionDialogState();
}

class _ContactSelectionDialogState extends State<_ContactSelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<flutter_contacts.Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = widget.contacts;
      } else {
        _filteredContacts = widget.contacts.where((contact) {
          final name = contact.displayName.toLowerCase();
          final phone = contact.phones.isNotEmpty
              ? contact.phones.first.number.toLowerCase()
              : '';
          final email = contact.emails.isNotEmpty
              ? contact.emails.first.address.toLowerCase()
              : '';
          return name.contains(query) ||
              phone.contains(query) ||
              email.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // Calculate available height accounting for keyboard and screen insets
    final screenHeight = mediaQuery.size.height;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final statusBarHeight = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    // Reserve space for dialog title (~56), search field (~60), padding (~80), and margins
    final reservedSpace = 200.0;
    final availableHeight = (screenHeight - keyboardHeight - statusBarHeight - bottomPadding - reservedSpace)
        .clamp(150.0, 400.0);
    
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectContact),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: availableHeight,
              ),
              child: _filteredContacts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          AppLocalizations.of(context)!.noContactsFound,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        return ListTile(
                          title: Text(contact.displayName),
                          subtitle: Text(
                            contact.phones.isNotEmpty
                                ? contact.phones.first.number
                                : contact.emails.isNotEmpty
                                    ? contact.emails.first.address
                                    : '',
                          ),
                          onTap: () => Navigator.pop(context, contact),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
