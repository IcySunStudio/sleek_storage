class TestModelAdvanced {
  const TestModelAdvanced({
    required this.string,
    required this.number,
    required this.doubleValue,
    required this.boolean,
    this.nullValue,
    required this.list,
    required this.nested,
  });
  factory TestModelAdvanced.fromJson(Map<String, dynamic> json) => TestModelAdvanced(
    string: json['string'] as String,
    number: json['number'] as int,
    doubleValue: (json['double'] as num).toDouble(),
    boolean: json['boolean'] as bool,
    nullValue: json['nullValue'],
    list: (json['list'] as List)
        .map((e) => ListItem.fromJson(e))
        .toList(),
    nested: Nested.fromJson(json['nested'] as Map<String, dynamic>),
  );

  static TestModelAdvanced random(int index) => TestModelAdvanced(
    string: 'hello$index',
    number: 40 + index,
    doubleValue: 3.0 + index * 0.1,
    boolean: index % 2 == 0,
    nullValue: index % 3 == 0 ? null : 'notNull$index',
    list: List.generate(12, (i) => ListItem(value: 'item${i + 1}_$index')),
    nested: Nested(
      innerString: 'world$index',
      innerList: List.generate(3, (i) => i + index),
      innerMap: InnerMap(
        flag: index % 2 == 1,
        value: index % 4 == 0 ? null : 'value$index',
      ),
    ),
  );

  final String string;
  final int number;
  final double doubleValue;
  final bool boolean;
  final dynamic nullValue;
  final List<ListItem> list;
  final Nested nested;

  Map<String, dynamic> toJson() => {
    'string': string,
    'number': number,
    'double': doubleValue,
    'boolean': boolean,
    'nullValue': nullValue,
    'list': list.map((e) => e.toJson()).toList(),
    'nested': nested.toJson(),
  };
}

class ListItem {
  const ListItem({
    required this.value,
  });
  factory ListItem.fromJson(Map<String, dynamic> json) => ListItem(
    value: json['value'] as String,
  );

  final String value;

  Map<String, dynamic> toJson() => {
    'value': value,
  };
}

class NestedMap {
  const NestedMap({required this.nestedMap});
  factory NestedMap.fromJson(Map<String, dynamic> json) => NestedMap(nestedMap: json['nestedMap'] as String);

  final String nestedMap;

  Map<String, dynamic> toJson() => {'nestedMap': nestedMap};
}

class Nested {
  const Nested({
    required this.innerString,
    required this.innerList,
    required this.innerMap,
  });
  factory Nested.fromJson(Map<String, dynamic> json) => Nested(
    innerString: json['innerString'] as String,
    innerList: (json['innerList'] as List).map((e) => e as int).toList(),
    innerMap: InnerMap.fromJson(json['innerMap'] as Map<String, dynamic>),
  );

  final String innerString;
  final List<int> innerList;
  final InnerMap innerMap;

  Map<String, dynamic> toJson() => {
    'innerString': innerString,
    'innerList': innerList,
    'innerMap': innerMap.toJson(),
  };
}

class InnerMap {
  const InnerMap({required this.flag, this.value});
  factory InnerMap.fromJson(Map<String, dynamic> json) => InnerMap(
    flag: json['flag'] as bool,
    value: json['value'],
  );

  final bool flag;
  final dynamic value;

  Map<String, dynamic> toJson() => {
    'flag': flag,
    'value': value,
  };
}
