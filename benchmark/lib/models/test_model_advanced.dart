import 'package:json_annotation/json_annotation.dart';

part 'test_model_advanced.g.dart';

@JsonSerializable()
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
  factory TestModelAdvanced.fromJson(Map<String, dynamic> json) => _$TestModelAdvancedFromJson(json);

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

  Map<String, dynamic> toJson() => _$TestModelAdvancedToJson(this);
}

@JsonSerializable()
class ListItem {
  const ListItem({
    required this.value,
  });
  factory ListItem.fromJson(Map<String, dynamic> json) => _$ListItemFromJson(json);

  final String value;

  Map<String, dynamic> toJson() => _$ListItemToJson(this);
}

@JsonSerializable()
class NestedMap {
  const NestedMap({required this.nestedMap});
  factory NestedMap.fromJson(Map<String, dynamic> json) => _$NestedMapFromJson(json);

  final String nestedMap;

  Map<String, dynamic> toJson() => _$NestedMapToJson(this);
}

@JsonSerializable()
class Nested {
  const Nested({
    required this.innerString,
    required this.innerList,
    required this.innerMap,
  });
  factory Nested.fromJson(Map<String, dynamic> json) => _$NestedFromJson(json);

  final String innerString;
  final List<int> innerList;
  final InnerMap innerMap;

  Map<String, dynamic> toJson() => _$NestedToJson(this);
}

@JsonSerializable()
class InnerMap {
  const InnerMap({required this.flag, this.value});
  factory InnerMap.fromJson(Map<String, dynamic> json) => _$InnerMapFromJson(json);

  final bool flag;
  final dynamic value;

  Map<String, dynamic> toJson() => _$InnerMapToJson(this);
}

class TestModelAdvancedHiveAdapter {
  const TestModelAdvancedHiveAdapter(this.encodedValue);

  final String encodedValue;
}
