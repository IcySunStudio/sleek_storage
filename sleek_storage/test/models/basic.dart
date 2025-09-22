class BasicClass {
  const BasicClass(this.id, this.value);
  factory BasicClass.fromJson(Map<String, dynamic> json) => BasicClass(
    json['id'] as String,
    json['value'] as int,
  );

  final String id;
  final int value;

  Map<String, dynamic> toJson() => {
    'id': id,
    'value': value,
  };
}
