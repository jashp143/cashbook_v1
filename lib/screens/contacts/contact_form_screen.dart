import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:permission_handler/permission_handler.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact permission is required to import contacts'),
            ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No contacts found on device')),
          );
        }
        return;
      }

      // Show contact selection dialog
      final selectedContact = await showDialog<flutter_contacts.Contact>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Contact'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact.displayName),
                  subtitle: Text(
                    contact.phones.isNotEmpty
                        ? contact.phones.first.number
                        : '',
                  ),
                  onTap: () => Navigator.pop(context, contact),
                );
              },
            ),
          ),
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing contact: $e')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_existingContact == null
                ? 'Contact created'
                : 'Contact updated'),
          ),
        );
        context.go('/contacts');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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
          title: Text(_existingContact == null ? 'New Contact' : 'Edit Contact'),
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
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email (Optional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _importFromDevice,
              icon: const Icon(Icons.contacts),
              label: const Text('Import from Device'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveContact,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save Contact'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
