class Student {
  String id;
  String name;
  double score;

  Student({
    required this.id,
    required this.name,
    required this.score,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
    };
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }

  @override
  String toString() => 'ID: $id | Tên: $name | Điểm: $score';
}
