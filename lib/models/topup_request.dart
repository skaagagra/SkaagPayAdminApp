class TopUpRequest {
  final int id;
  final String userPhone;
  final String amount;
  final String status;
  final String transactionReference;
  final String createdAt;

  TopUpRequest({
    required this.id,
    required this.userPhone,
    required this.amount,
    required this.status,
    required this.transactionReference,
    required this.createdAt,
  });

  factory TopUpRequest.fromJson(Map<String, dynamic> json) {
    return TopUpRequest(
      id: json['id'],
      userPhone: json['user_phone'] ?? 'Unknown', 
      amount: json['amount'].toString(),
      status: json['status'],
      transactionReference: json['transaction_reference'] ?? 'N/A',
      createdAt: json['created_at'],
    );
  }
}
