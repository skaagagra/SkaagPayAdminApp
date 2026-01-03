class Plan {
  final int id;
  final int operatorId;
  final String operatorName;
  final String amount;
  final String data;
  final String validity;
  final String additionalBenefits;
  final String planType;

  Plan({
    required this.id,
    required this.operatorId,
    required this.operatorName,
    required this.amount,
    required this.data,
    required this.validity,
    required this.additionalBenefits,
    required this.planType,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      operatorId: json['operator'],
      operatorName: json['operator_name'] ?? 'Unknown',
      amount: json['amount'].toString(),
      data: json['data'] ?? '',
      validity: json['validity'] ?? '',
      additionalBenefits: json['additional_benefits'] ?? '',
      planType: json['plan_type'] ?? 'OTHER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operator': operatorId,
      'amount': amount,
      'data': data,
      'validity': validity,
      'additional_benefits': additionalBenefits,
      'plan_type': planType,
    };
  }
}
