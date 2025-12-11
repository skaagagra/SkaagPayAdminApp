class RechargeRequest {
  final int id;
  final String mobileNumber;
  final String operator;
  final String amount;
  final String status;
  final String createdAt;

  RechargeRequest({
    required this.id,
    required this.mobileNumber,
    required this.operator,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory RechargeRequest.fromJson(Map<String, dynamic> json) {
    return RechargeRequest(
      id: json['id'],
      mobileNumber: json['mobile_number'],
      operator: json['operator'],
      amount: json['amount'].toString(),
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
