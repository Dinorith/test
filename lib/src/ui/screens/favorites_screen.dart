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
      backgroundColor: const Color(0xFF0F0F1E),
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
            "❤️ My Favorites",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFFD93D),
              letterSpacing: 0.5,
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6BCB77).withOpacity(0.2),
                border: Border.all(color: const Color(0xFF6BCB77), width: 1.5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6BCB77).withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Text(
                "$count",
                style: const TextStyle(
                  color: Color(0xFF6BCB77),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2A3E), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                    child: Stack(
                      children: [
                        Image.network(
                          meal.image ?? '',
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 220,
                            color: const Color(0xFF0F0F1E),
                            child: const Icon(Icons.fastfood, color: Color(0xFFFFD93D), size: 60),
                          ),
                        ),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Remove button with gradient
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(favoritesProvider.notifier).remove(entity);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Removed from favorites'),
                          backgroundColor: const Color(0xFF6BCB77),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF6B6B),
                        size: 22,
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
                      color: Color(0xFFFFD93D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6BCB77).withOpacity(0.2),
                          border: Border.all(color: const Color(0xFF6BCB77), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          meal.category ?? 'General',
                          style: const TextStyle(
                            color: Color(0xFF6BCB77),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B).withOpacity(0.2),
                          border: Border.all(color: const Color(0xFFFF6B6B), width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          meal.area ?? 'Unknown',
                          style: const TextStyle(
                            color: Color(0xFFFF6B6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6BCB77), width: 2),
            ),
            child: const Icon(Icons.favorite_border, size: 50, color: Color(0xFF6BCB77)),
          ),
          const SizedBox(height: 24),
          const Text(
            "❤️ No Favorites Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD93D),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Your saved recipes will appear here.",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B0C0),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6BCB77).withOpacity(0.2),
              border: Border.all(color: const Color(0xFF6BCB77), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "🍽️ Start Exploring",
              style: TextStyle(
                color: Color(0xFF6BCB77),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
