import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'api_provider.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  
  try {
    final response = await api.getCategories();

    // response.data should be a List directly
    if (response.data is! List) {
      throw Exception('Unexpected response format: ${response.data.runtimeType}');
    }
    
    final categoriesList = response.data as List;
    return categoriesList
      .cast<Map<String, dynamic>>()
      .map((e) => Category.fromJson(e))
      .toList();
  } catch (e) {
    print('Error fetching categories: $e');
    rethrow;
  }
});
