class Transaction {
  final int? id;
  final String type; // 'income', 'expense', 'transfer'
  final double amount;
  final int? accountId; // For income/expense: account, For transfer: from_account
  final int? secondAccountId; // For transfer: to_account
  final int? contactId;
  final String? billNumber;
  final String? companyName;
  final String? remark;
  final String date;
  final String createdAt;

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    this.accountId,
    this.secondAccountId,
    this.contactId,
    this.billNumber,
    this.companyName,
    this.remark,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'account_id': accountId,
      'second_account_id': secondAccountId,
      'contact_id': contactId,
      'bill_number': billNumber,
      'company_name': companyName,
      'remark': remark,
      'date': date,
      'created_at': createdAt,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      accountId: map['account_id'] as int?,
      secondAccountId: map['second_account_id'] as int?,
      contactId: map['contact_id'] as int?,
      billNumber: map['bill_number'] as String?,
      companyName: map['company_name'] as String?,
      remark: map['remark'] as String?,
      date: map['date'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Transaction copyWith({
    int? id,
    String? type,
    double? amount,
    int? accountId,
    int? secondAccountId,
    int? contactId,
    String? billNumber,
    String? companyName,
    String? remark,
    String? date,
    String? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      secondAccountId: secondAccountId ?? this.secondAccountId,
      contactId: contactId ?? this.contactId,
      billNumber: billNumber ?? this.billNumber,
      companyName: companyName ?? this.companyName,
      remark: remark ?? this.remark,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

