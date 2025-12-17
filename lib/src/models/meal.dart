import 'package:json_annotation/json_annotation.dart';
part 'meal.g.dart';

@JsonSerializable()
class Meal {
  // Matches "id" in your JSON
  @JsonKey(name: 'id')
  final dynamic idMeal; 

  // Matches "meal" in your JSON
  @JsonKey(name: 'meal')
  final String? name;

  // Matches "mealThumb" in your JSON
  @JsonKey(name: 'mealThumb')
  final String? image;

  // Matches "instructions" in your JSON
  @JsonKey(name: 'instructions')
  final String? instructions;

  // Matches "ingredients" List in your JSON
  final List<Map<String, dynamic>>? ingredients;

  final String? category;
  final String? area;

  Meal({
    required this.idMeal,
    this.name,
    this.image,
    this.instructions,
    this.ingredients,
    this.category,
    this.area,
  });

  String get id => idMeal.toString();

  factory Meal.fromJson(Map<String, dynamic> json) => _$MealFromJson(json);
  Map<String, dynamic> toJson() => _$MealToJson(this);
}