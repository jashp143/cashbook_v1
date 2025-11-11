class Contact {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String createdAt;

  Contact({
    this.id,
    required this.name,
    this.phone,
    this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'created_at': createdAt,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

