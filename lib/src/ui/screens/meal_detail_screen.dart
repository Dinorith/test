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
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text("Recipe Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: const Color(0xFFFF6B6B),
              size: 26,
            ),
            onPressed: () {
              mealDetailsAsync.whenData((data) => _toggleFavorite(ref, isFav, data, favorites));
            },
          )
        ],
      ),
      body: mealDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFFD93D))),
        error: (e, _) => Center(
          child: Text("Error loading details", style: TextStyle(color: Colors.grey[400])),
        ),
        data: (mealData) {
          if (mealData.isEmpty) return const Center(child: Text("No details found.", style: TextStyle(color: Colors.white70)));

          final ingredients = (mealData['ingredients'] as List? ?? []);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Image with modern overlay
                Stack(
                  children: [
                    Hero(
                      tag: "meal_${meal.idMeal}",
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              meal.image ?? mealData['mealThumb'] ?? '',
                              height: 320,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 320,
                                color: const Color(0xFF1A1A2E),
                                child: const Icon(Icons.fastfood, size: 80, color: Color(0xFFFFD93D)),
                              ),
                            ),
                            // Overlay gradient
                            Container(
                              height: 320,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe Title
                      Text(
                        mealData['meal'] ?? meal.name ?? '',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD93D),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Category and Area Tags
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withOpacity(0.2),
                              border: Border.all(color: const Color(0xFFFF6B6B), width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "🍽️ ${mealData['category'] ?? ''}",
                              style: const TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6BCB77).withOpacity(0.2),
                              border: Border.all(color: const Color(0xFF6BCB77), width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "🌍 ${mealData['area'] ?? ''}",
                              style: const TextStyle(
                                color: Color(0xFF6BCB77),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // INSTRUCTIONS SECTION
                      _buildSectionHeader("👨‍🍳 Preparation Steps"),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFD93D).withOpacity(0.3), width: 1.5),
                        ),
                        child: Text(
                          mealData['instructions'] ?? '',
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.9,
                            color: Color(0xFFE0E0E0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // INGREDIENTS SECTION
                      _buildSectionHeader("🥘 What You Need"),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF6BCB77).withOpacity(0.3), width: 1.5),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: ingredients.length,
                          separatorBuilder: (_, __) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 1,
                            color: const Color(0xFF2A2A3E),
                          ),
                          itemBuilder: (context, index) {
                            final ing = ingredients[index];
                            final isEven = index.isEven;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              color: isEven ? const Color(0xFF0F0F1E) : const Color(0xFF1A1A2E),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF6BCB77).withOpacity(0.3),
                                      border: Border.all(color: const Color(0xFF6BCB77), width: 1.5),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "✓",
                                        style: TextStyle(
                                          color: Color(0xFF6BCB77),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ing['ingredient'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFFFD93D),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          ing['measure'] ?? 'As needed',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFFB0B0C0),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFFFFD93D),
        letterSpacing: 0.8,
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