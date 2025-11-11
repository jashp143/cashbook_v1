import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/account.dart';
import 'models/contact.dart';
import 'models/transaction.dart' as model;
import 'models/receipt.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cashbook.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Create contacts table
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        account_id INTEGER,
        second_account_id INTEGER,
        contact_id INTEGER,
        bill_number TEXT,
        company_name TEXT,
        remark TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id),
        FOREIGN KEY (second_account_id) REFERENCES accounts (id),
        FOREIGN KEY (contact_id) REFERENCES contacts (id)
      )
    ''');

    // Create receipts table
    await db.execute('''
      CREATE TABLE receipts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id)
      )
    ''');

    // Initialize with default "Khata Vahi" account
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'accounts',
      {
        'name': 'Khata Vahi',
        'balance': 0.0,
        'created_at': now,
      },
    );
  }

  // Account operations
  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await database;
    final result = await db.query('accounts', orderBy: 'created_at DESC');
    return result.map((map) => Account.fromMap(map)).toList();
  }

  Future<Account?> getAccount(int id) async {
    final db = await database;
    final result = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Account.fromMap(result.first);
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> updateAccountBalance(int accountId, double newBalance) async {
    final db = await database;
    return await db.update(
      'accounts',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Contact operations
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final result = await db.query('contacts', orderBy: 'name ASC');
    return result.map((map) => Contact.fromMap(map)).toList();
  }

  Future<Contact?> getContact(int id) async {
    final db = await database;
    final result = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Contact.fromMap(result.first);
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction operations
  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<model.Transaction>> getAllTransactions() async {
    final db = await database;
    final result = await db.query(
      'transactions',
      orderBy: 'date DESC, created_at DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByAccount(int accountId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC, created_at DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByContact(int contactId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'contact_id = ?',
      whereArgs: [contactId],
      orderBy: 'date DESC, created_at DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getTransactionsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC, created_at DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<List<model.Transaction>> getFilteredTransactions({
    int? accountId,
    int? contactId,
    String? startDate,
    String? endDate,
  }) async {
    final db = await database;
    String where = '1=1';
    List<dynamic> whereArgs = [];

    if (accountId != null) {
      // Include transactions where account is either account_id or second_account_id (for transfers)
      where += ' AND (account_id = ? OR second_account_id = ?)';
      whereArgs.add(accountId);
      whereArgs.add(accountId);
    }

    if (contactId != null) {
      where += ' AND contact_id = ?';
      whereArgs.add(contactId);
    }

    if (startDate != null) {
      where += ' AND date >= ?';
      whereArgs.add(startDate);
    }

    if (endDate != null) {
      where += ' AND date <= ?';
      whereArgs.add(endDate);
    }

    final result = await db.query(
      'transactions',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC, created_at DESC',
    );
    return result.map((map) => model.Transaction.fromMap(map)).toList();
  }

  Future<model.Transaction?> getTransaction(int id) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return model.Transaction.fromMap(result.first);
  }

  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Receipt operations
  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    return await db.insert('receipts', receipt.toMap());
  }

  Future<List<Receipt>> getReceiptsByTransaction(int transactionId) async {
    final db = await database;
    final result = await db.query(
      'receipts',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
    return result.map((map) => Receipt.fromMap(map)).toList();
  }

  Future<int> deleteReceipt(int id) async {
    final db = await database;
    return await db.delete(
      'receipts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteReceiptsByTransaction(int transactionId) async {
    final db = await database;
    return await db.delete(
      'receipts',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

