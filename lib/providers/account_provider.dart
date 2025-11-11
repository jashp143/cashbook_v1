import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../database/models/account.dart';

class AccountProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Account> _accounts = [];
  bool _isLoading = false;
  int? _selectedAccountId;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  int? get selectedAccountId => _selectedAccountId;
  
  Account? get selectedAccount {
    if (_selectedAccountId == null || _selectedAccountId == -1) return null;
    return getAccountById(_selectedAccountId);
  }

  void setSelectedAccount(int? accountId) {
    if (_selectedAccountId != accountId) {
      _selectedAccountId = accountId;
      notifyListeners();
    } else {
      // Even if same value, notify to ensure UI updates
      notifyListeners();
    }
  }

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _accounts = await _db.getAllAccounts();
    } catch (e) {
      debugPrint('Error loading accounts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addAccount(Account account) async {
    try {
      final id = await _db.insertAccount(account);
      await loadAccounts();
      return id;
    } catch (e) {
      debugPrint('Error adding account: $e');
      rethrow;
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _db.updateAccount(account);
      await loadAccounts();
    } catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }

  Future<void> updateAccountBalance(int accountId, double newBalance) async {
    try {
      await _db.updateAccountBalance(accountId, newBalance);
      await loadAccounts();
    } catch (e) {
      debugPrint('Error updating account balance: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await _db.deleteAccount(id);
      await loadAccounts();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  Account? getAccountById(int? id) {
    if (id == null) return null;
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }
}

