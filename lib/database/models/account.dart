class Account {
  final int? id;
  final String name;
  final double balance;
  final String? accountNumber;
  final String? note;
  final String createdAt;

  Account({
    this.id,
    required this.name,
    this.balance = 0.0,
    this.accountNumber,
    this.note,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'account_number': accountNumber,
      'note': note,
      'created_at': createdAt,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      accountNumber: map['account_number'] as String?,
      note: map['note'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    String? accountNumber,
    String? note,
    String? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      accountNumber: accountNumber ?? this.accountNumber,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

