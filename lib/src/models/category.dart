import 'package:json_annotation/json_annotation.dart';
part 'category.g.dart';

@JsonSerializable()
class Category {
  final String id;
  final String category;
  final String categoryThumb;
  final String categoryDescription;

  Category({
    required this.id,
    required this.category,
    required this.categoryThumb,
    required this.categoryDescription,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
