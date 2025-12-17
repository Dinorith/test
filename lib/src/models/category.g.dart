// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) => Category(
      id: json['id'] as String,
      category: json['category'] as String,
      categoryThumb: json['categoryThumb'] as String,
      categoryDescription: json['categoryDescription'] as String,
    );

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'categoryThumb': instance.categoryThumb,
      'categoryDescription': instance.categoryDescription,
    };
