import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal.dart';
import 'api_provider.dart';

final mealsProvider = FutureProvider<List<Meal>>((ref) async {
  try {
    final api = ref.watch(apiServiceProvider);
    final response = await api.getMeals();

    print('DEBUG: Response status: ${response.statusCode}');
    print('DEBUG: Response data type: ${response.data.runtimeType}');
    print('DEBUG: Response data: ${response.data}');
    
    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode} - ${response.statusMessage}');
    }
    
    // response.data should be a List directly
    if (response.data is! List) {
      throw Exception('Unexpected response format: ${response.data.runtimeType}');
    }
    
    final mealsList = response.data as List;
    print('DEBUG: Meals list length: ${mealsList.length}');
    
    if (mealsList.isEmpty) {
      return [];
    }
    
    print('DEBUG: First item: ${mealsList[0]}');
    
    return mealsList
      .cast<Map<String, dynamic>>()
      .map((json) => Meal.fromJson(json))
      .toList();
  } catch (e, st) {
    print('ERROR in mealsProvider: $e');
    print('Stack trace: $st');
    rethrow;
  }
});

final popularMealsProvider = FutureProvider<List<Meal>>((ref) async {
  final meals = await ref.watch(mealsProvider.future);
  // Return first 5 meals as popular
  return meals.take(5).toList();
});

final randomMealProvider = FutureProvider<Meal?>((ref) async {
  final meals = await ref.watch(mealsProvider.future);
  if (meals.isEmpty) return null;
  meals.shuffle();
  return meals.first;
});
