class Account {
  final int? id;
  final String name;
  final double balance;
  final String createdAt;

  Account({
    this.id,
    required this.name,
    this.balance = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'created_at': createdAt,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      name: map['name'] as String,
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] as String,
    );
  }

  Account copyWith({
    int? id,
    String? name,
    double? balance,
    String? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

