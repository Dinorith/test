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
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        title: Text(meal.name ?? "Recipe", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () {
              mealDetailsAsync.whenData((data) => _toggleFavorite(ref, isFav, data, favorites));
            },
          )
        ],
      ),
      body: mealDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF667EEA))),
        error: (e, _) => Center(
          child: Text("Error loading details", style: TextStyle(color: Colors.grey[600])),
        ),
        data: (mealData) {
          if (mealData.isEmpty) return const Center(child: Text("No details found."));

          final ingredients = (mealData['ingredients'] as List? ?? []);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image with overlay
                Stack(
                  children: [
                    Hero(
                      tag: "meal_${meal.idMeal}",
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        child: Image.network(
                          meal.image ?? mealData['mealThumb'] ?? '',
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 300,
                            color: const Color(0xFFE8E8F0),
                            child: const Icon(Icons.fastfood, size: 60, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Title
                      Text(
                        mealData['meal'] ?? meal.name ?? '',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              mealData['category'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8F0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              mealData['area'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFF667EEA),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // INSTRUCTIONS
                      _buildHeader("👨‍🍳 How to Prepare"),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          mealData['instructions'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // INGREDIENTS
                      _buildHeader("🥗 Ingredients"),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ingredients.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: Color(0xFFE8E8F0),
                          ),
                          itemBuilder: (context, index) {
                            final ing = ingredients[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      ing['ingredient'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ing['measure'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF667EEA),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.5,
      ),
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