import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../database/models/transaction.dart';
import '../database/models/receipt.dart';
import 'account_provider.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // Summary calculations - these aggregate all transactions in _transactions
  // When "All Accounts" is selected, _transactions contains all transactions from all accounts
  // When a specific account is selected, _transactions contains only that account's transactions
  double get totalBalance {
    double balance = 0.0;
    for (var transaction in _transactions) {
      if (transaction.type == 'income') {
        balance += transaction.amount;
      } else if (transaction.type == 'expense') {
        balance -= transaction.amount;
      }
      // Transfer doesn't affect total balance (it's just moving money between accounts)
    }
    return balance;
  }

  double get totalIncome {
    // Aggregate all income transactions from the current transaction list
    return _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    // Aggregate all expense transactions from the current transaction list
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Loads ALL transactions from ALL accounts without any filtering
  /// Used when "All Accounts" is selected to aggregate transactions across all accounts
  /// This method loads every transaction from the database regardless of account
  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get all transactions from database - no account filter
      // This aggregates all transactions from all accounts
      _transactions = List<Transaction>.from(await _db.getAllTransactions());
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFilteredTransactions({
    int? accountId,
    int? contactId,
    String? startDate,
    String? endDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = List<Transaction>.from(await _db.getFilteredTransactions(
        accountId: accountId,
        contactId: contactId,
        startDate: startDate,
        endDate: endDate,
      ));
    } catch (e) {
      debugPrint('Error loading filtered transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> addTransaction(
    Transaction transaction,
    List<Receipt>? receipts,
    AccountProvider accountProvider,
  ) async {
    try {
      // Insert transaction
      final transactionId = await _db.insertTransaction(transaction);

      // Insert receipts if any
      if (receipts != null && receipts.isNotEmpty) {
        for (var receipt in receipts) {
          await _db.insertReceipt(
            receipt.copyWith(transactionId: transactionId),
          );
        }
      }

      // Update account balances
      await _updateAccountBalances(transaction, accountProvider);

      // Reload transactions
      await loadTransactions();

      return transactionId;
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> _updateAccountBalances(
    Transaction transaction,
    AccountProvider accountProvider,
  ) async {
    if (transaction.type == 'income' && transaction.accountId != null) {
      final account = accountProvider.getAccountById(transaction.accountId);
      if (account != null) {
        final newBalance = account.balance + transaction.amount;
        await accountProvider.updateAccountBalance(
          transaction.accountId!,
          newBalance,
        );
      }
    } else if (transaction.type == 'expense' && transaction.accountId != null) {
      final account = accountProvider.getAccountById(transaction.accountId);
      if (account != null) {
        final newBalance = account.balance - transaction.amount;
        await accountProvider.updateAccountBalance(
          transaction.accountId!,
          newBalance,
        );
      }
    } else if (transaction.type == 'transfer') {
      // For transfer: debit from account, credit to secondAccount
      if (transaction.accountId != null) {
        final fromAccount = accountProvider.getAccountById(transaction.accountId);
        if (fromAccount != null) {
          final newBalance = fromAccount.balance - transaction.amount;
          await accountProvider.updateAccountBalance(
            transaction.accountId!,
            newBalance,
          );
        }
      }
      if (transaction.secondAccountId != null) {
        final toAccount = accountProvider.getAccountById(transaction.secondAccountId);
        if (toAccount != null) {
          final newBalance = toAccount.balance + transaction.amount;
          await accountProvider.updateAccountBalance(
            transaction.secondAccountId!,
            newBalance,
          );
        }
      }
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _db.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      // Delete associated receipts
      await _db.deleteReceiptsByTransaction(id);
      // Delete transaction
      await _db.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<List<Receipt>> getReceiptsForTransaction(int transactionId) async {
    try {
      return await _db.getReceiptsByTransaction(transactionId);
    } catch (e) {
      debugPrint('Error loading receipts: $e');
      return [];
    }
  }
}

