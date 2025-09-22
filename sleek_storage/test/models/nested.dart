

class MyClass {
  const MyClass({
    required this.string,
    required this.number,
    required this.doubleValue,
    required this.boolean,
    this.nullValue,
    required this.list,
    required this.nested,
  });
  factory MyClass.fromJson(Map<String, dynamic> json) => MyClass(
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

  static MyClass random(int index) => MyClass(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MyClass &&
              runtimeType == other.runtimeType &&
              string == other.string &&
              number == other.number &&
              doubleValue == other.doubleValue &&
              boolean == other.boolean &&
              nullValue == other.nullValue &&
              iterableEquals(list, other.list) &&
              nested == other.nested;

  @override
  int get hashCode =>
      string.hashCode ^
      number.hashCode ^
      doubleValue.hashCode ^
      boolean.hashCode ^
      nullValue.hashCode ^
      list.hashCode ^
      nested.hashCode;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ListItem &&
              runtimeType == other.runtimeType &&
              value == other.value;

  @override
  int get hashCode => value.hashCode;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Nested &&
              runtimeType == other.runtimeType &&
              innerString == other.innerString &&
              iterableEquals(innerList, other.innerList) &&
              innerMap == other.innerMap;

  @override
  int get hashCode =>
      innerString.hashCode ^
      innerList.hashCode ^
      innerMap.hashCode;
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is InnerMap &&
              runtimeType == other.runtimeType &&
              flag == other.flag &&
              value == other.value;

  @override
  int get hashCode => flag.hashCode ^ value.hashCode;
}

/// Compares two iterables for deep equality.
/// Copied from flutter's listEquals()
///
/// Returns true if the iterables are both null, or if they are both non-null, have
/// the same length, and contain the same members in the same order. Returns
/// false otherwise.
///
/// The term "deep" above refers to the first level of equality: if the elements
/// are maps, lists, sets, or other collections/composite objects, then the
/// values of those elements are not compared element by element unless their
/// equality operators ([Object.operator==]) do so.
bool iterableEquals<T>(Iterable<T>? a, Iterable<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  final ita = a.iterator;
  final itb = b.iterator;
  while (ita.moveNext() && itb.moveNext()) {
    if (ita.current != itb.current) return false;
  }
  return true;
}
