import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/favorites_provider.dart';
import '../../models/meal.dart';
import '../../db/favorite_entity.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<FavoriteMeal> favorites = ref.watch(favoritesProvider);
    final favoriteCount = favorites.length;

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(favoriteCount),
            Expanded(
              child: favorites.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final favEntity = favorites[index];
                        
                        // CONVERSION: Transform DB Entity to UI Model
                        final mealModel = Meal(
                          idMeal: favEntity.id.toString(),
                          name: favEntity.name,
                          image: favEntity.image,
                          category: favEntity.category,
                          area: favEntity.area,
                        );

                        return _buildLargeFavoriteCard(context, ref, favEntity, mealModel);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "My Favorites",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$count", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLargeFavoriteCard(BuildContext context, WidgetRef ref, FavoriteMeal entity, Meal meal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Hero(
                  tag: "meal_${meal.idMeal}",
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      meal.image ?? '',
                      width: double.infinity,
                      height: 220, // Large height for full-width card
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 220, 
                        color: Colors.grey[100],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Remove (Red Heart) button
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(favoritesProvider.notifier).remove(entity);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded, 
                        color: Colors.red, 
                        size: 22
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name ?? 'Unnamed',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 18,
                      color: Colors.black
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${meal.category} • ${meal.area}",
                    style: const TextStyle(
                      color: Colors.red, 
                      fontSize: 14,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 80, color: Colors.red[50]),
          const SizedBox(height: 16),
          const Text(
            "No favorites yet", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const Text(
            "Recipes you heart will appear here.", 
            style: TextStyle(color: Colors.grey)
          ),
        ],
      ),
    );
  }
}