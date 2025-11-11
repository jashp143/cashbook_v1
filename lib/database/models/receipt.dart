class Receipt {
  final int? id;
  final int transactionId;
  final String filePath;
  final String fileType; // 'image' or 'pdf'
  final String createdAt;

  Receipt({
    this.id,
    required this.transactionId,
    required this.filePath,
    required this.fileType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'file_path': filePath,
      'file_type': fileType,
      'created_at': createdAt,
    };
  }

  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  Receipt copyWith({
    int? id,
    int? transactionId,
    String? filePath,
    String? fileType,
    String? createdAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

