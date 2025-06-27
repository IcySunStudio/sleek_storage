import 'package:json_annotation/json_annotation.dart';

part 'test_model.g.dart';

@JsonSerializable()
class TestModelBasic {
  const TestModelBasic({
    required this.fieldZero,
    required this.fieldOne,
    required this.fieldTwo,
    required this.fieldThree,
    required this.fieldFour,
    required this.fieldFive,
    required this.fieldSix,
    required this.fieldSeven,
    required this.fieldEight,
    required this.fieldNine,
  });
  factory TestModelBasic.example() => const TestModelBasic(
    fieldZero: 0,
    fieldOne: 1,
    fieldTwo: 2,
    fieldThree: 3,
    fieldFour: 4,
    fieldFive: 5,
    fieldSix: 6,
    fieldSeven: 7,
    fieldEight: 8,
    fieldNine: 9,
  );
  factory TestModelBasic.fromJson(Map<String, dynamic> json) => _$TestModelFromJson(json);

  final int fieldZero;
  final int fieldOne;
  final int fieldTwo;
  final int fieldThree;
  final int fieldFour;
  final int fieldFive;
  final int fieldSix;
  final int fieldSeven;
  final int fieldEight;
  final int fieldNine;

  Map<String, dynamic> toJson() => _$TestModelToJson(this);
}
