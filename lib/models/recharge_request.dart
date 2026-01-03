class RechargeRequest {
  final int id;
  final int userId;
  final String userName;
  final String mobileNumber;
  final String operator;
  final String amount;
  final String status;
  final String createdAt;

  RechargeRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.mobileNumber,
    required this.operator,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory RechargeRequest.fromJson(Map<String, dynamic> json) {
    return RechargeRequest(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? 'Unknown User',
      mobileNumber: json['mobile_number'],
      operator: json['operator'],
      amount: json['amount'].toString(),
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
