class User {
  final int id;
  final String phoneNumber;
  final String fullName;
  final bool isActive;
  final bool isAdmin;
  final String walletBalance;
  final String createdAt;

  User({
    required this.id, 
    required this.phoneNumber,
    required this.fullName, 
    required this.isActive,
    required this.isAdmin,
    required this.walletBalance,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phone_number'] ?? '',
      fullName: json['full_name'] ?? '',
      isActive: json['is_active'] ?? true,
      isAdmin: json['is_admin'] ?? false,
      walletBalance: json['wallet_balance']?.toString() ?? '0.00',
      createdAt: json['created_at'] ?? '',
    );
  }
}
