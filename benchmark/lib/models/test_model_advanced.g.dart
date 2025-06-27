// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_model_advanced.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestModelAdvanced _$TestModelAdvancedFromJson(Map<String, dynamic> json) =>
    TestModelAdvanced(
      string: json['string'] as String,
      number: (json['number'] as num).toInt(),
      doubleValue: (json['doubleValue'] as num).toDouble(),
      boolean: json['boolean'] as bool,
      nullValue: json['nullValue'],
      list: (json['list'] as List<dynamic>)
          .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nested: Nested.fromJson(json['nested'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TestModelAdvancedToJson(TestModelAdvanced instance) =>
    <String, dynamic>{
      'string': instance.string,
      'number': instance.number,
      'doubleValue': instance.doubleValue,
      'boolean': instance.boolean,
      'nullValue': instance.nullValue,
      'list': instance.list,
      'nested': instance.nested,
    };

ListItem _$ListItemFromJson(Map<String, dynamic> json) => ListItem(
      value: json['value'] as String,
    );

Map<String, dynamic> _$ListItemToJson(ListItem instance) => <String, dynamic>{
      'value': instance.value,
    };

NestedMap _$NestedMapFromJson(Map<String, dynamic> json) => NestedMap(
      nestedMap: json['nestedMap'] as String,
    );

Map<String, dynamic> _$NestedMapToJson(NestedMap instance) => <String, dynamic>{
      'nestedMap': instance.nestedMap,
    };

Nested _$NestedFromJson(Map<String, dynamic> json) => Nested(
      innerString: json['innerString'] as String,
      innerList: (json['innerList'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      innerMap: InnerMap.fromJson(json['innerMap'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NestedToJson(Nested instance) => <String, dynamic>{
      'innerString': instance.innerString,
      'innerList': instance.innerList,
      'innerMap': instance.innerMap,
    };

InnerMap _$InnerMapFromJson(Map<String, dynamic> json) => InnerMap(
      flag: json['flag'] as bool,
      value: json['value'],
    );

Map<String, dynamic> _$InnerMapToJson(InnerMap instance) => <String, dynamic>{
      'flag': instance.flag,
      'value': instance.value,
    };
