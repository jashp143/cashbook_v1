import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../database/models/contact.dart';

class ContactProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Contact> _contacts = [];
  bool _isLoading = false;

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;

  Future<void> loadContacts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _contacts = await _db.getAllContacts();
    } catch (e) {
      debugPrint('Error loading contacts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addContact(Contact contact) async {
    try {
      final id = await _db.insertContact(contact);
      await loadContacts();
      return id;
    } catch (e) {
      debugPrint('Error adding contact: $e');
      rethrow;
    }
  }

  Future<void> updateContact(Contact contact) async {
    try {
      await _db.updateContact(contact);
      await loadContacts();
    } catch (e) {
      debugPrint('Error updating contact: $e');
      rethrow;
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      await _db.deleteContact(id);
      await loadContacts();
    } catch (e) {
      debugPrint('Error deleting contact: $e');
      rethrow;
    }
  }

  Contact? getContactById(int? id) {
    if (id == null) return null;
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (e) {
      return null;
    }
  }
}

