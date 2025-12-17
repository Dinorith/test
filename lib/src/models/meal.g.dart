// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Meal _$MealFromJson(Map<String, dynamic> json) => Meal(
      idMeal: json['id'],
      name: json['meal'] as String?,
      image: json['mealThumb'] as String?,
      instructions: json['instructions'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      category: json['category'] as String?,
      area: json['area'] as String?,
    );

Map<String, dynamic> _$MealToJson(Meal instance) => <String, dynamic>{
      'id': instance.idMeal,
      'meal': instance.name,
      'mealThumb': instance.image,
      'instructions': instance.instructions,
      'ingredients': instance.ingredients,
      'category': instance.category,
      'area': instance.area,
    };
