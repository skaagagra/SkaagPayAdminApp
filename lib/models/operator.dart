class Operator {
  final int id;
  final String name;
  final String category;

  Operator({
    required this.id,
    required this.name,
    required this.category,
  });

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: json['id'],
      name: json['name'],
      category: json['category'],
    );
  }
}
