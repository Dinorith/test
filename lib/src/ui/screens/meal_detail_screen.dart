import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/api_provider.dart';
import '../../models/meal.dart';
import '../../db/favorite_entity.dart';

// Fetch detailed meal data
final mealDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, mealId) async {
  final apiService = ref.read(apiServiceProvider);
  try {
    final response = await apiService.getMealById(int.parse(mealId));
    return response.data != null ? Map<String, dynamic>.from(response.data) : {};
  } catch (e) {
    return {};
  }
});

class MealDetailScreen extends ConsumerWidget {
  final Meal meal;
  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String mealIdStr = meal.idMeal.toString();
    final mealDetailsAsync = ref.watch(mealDetailProvider(mealIdStr));
    final List<FavoriteMeal> favorites = ref.watch(favoritesProvider);
    final isFav = favorites.any((e) => e.id.toString() == mealIdStr);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(meal.name ?? "Recipe", style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              // Toggle logic (Assuming the logic in your toggle method)
              mealDetailsAsync.whenData((data) => _toggleFavorite(ref, isFav, data, favorites));
            },
          )
        ],
      ),
      body: mealDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (e, _) => Center(child: Text("Error loading details")),
        data: (mealData) {
          if (mealData.isEmpty) return const Center(child: Text("No details found."));

          final ingredients = (mealData['ingredients'] as List? ?? []);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image
                Hero(
                  tag: "meal_${meal.idMeal}",
                  child: Image.network(
                    meal.image ?? mealData['mealThumb'] ?? '',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Title
                      Text(
                        mealData['meal'] ?? meal.name ?? '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${mealData['category']} | ${mealData['area']}",
                        style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w500),
                      ),
                      
                      const Divider(height: 40, thickness: 1),

                      // 1. INSTRUCTIONS FIRST
                      _buildHeader("How to Prepare"),
                      const SizedBox(height: 12),
                      Text(
                        mealData['instructions'] ?? '',
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),

                      const SizedBox(height: 40),

                      // 2. INGREDIENTS AT THE BOTTOM
                      _buildHeader("Ingredients"),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ingredients.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                          itemBuilder: (context, index) {
                            final ing = ingredients[index];
                            return ListTile(
                              leading: const Icon(Icons.circle, size: 8, color: Colors.red),
                              title: Text(ing['ingredient'] ?? '', style: const TextStyle(fontSize: 14)),
                              trailing: Text(
                                ing['measure'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: Colors.red),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ],
    );
  }

  void _toggleFavorite(WidgetRef ref, bool isFav, Map<String, dynamic> data, List<FavoriteMeal> favorites) {
    final notifier = ref.read(favoritesProvider.notifier);
    final String currentId = meal.idMeal.toString();

    if (isFav) {
      final toRemove = favorites.firstWhere((e) => e.id.toString() == currentId);
      notifier.remove(toRemove);
    } else {
      notifier.add(FavoriteMeal(
        int.parse(currentId),
        meal.name ?? data['meal'] ?? '',
        meal.image ?? data['mealThumb'] ?? '',
        data['category'] ?? '',
        data['area'] ?? '',
      ));
    }
  }
}