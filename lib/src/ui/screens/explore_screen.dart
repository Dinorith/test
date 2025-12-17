import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/meal.dart';
import '../../providers/meal_provider.dart';
import '../../providers/category_provider.dart';
import 'meal_detail_screen.dart';

// Define the name for the 'All' category
const String allCategoryName = 'All';


class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  int selectedCategoryIndex = 0;

  void _selectCategory(int index) {
    setState(() {
      selectedCategoryIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🔍 Explore Recipes",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFFD93D),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Discover delicious dishes from around the world",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB0B0C0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: categoriesAsync.when(
                data: (categories) {
                  final categoryList = [allCategoryName, ...categories.map((c) => c.category)];
                  return SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryList.length,
                      itemBuilder: (context, index) {
                        final isSelected = selectedCategoryIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () => _selectCategory(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF1A1A2E) : const Color(0xFF1A1A2E),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFFFD93D) : const Color(0xFF2A2A3E),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Text(
                                  categoryList[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? const Color(0xFFFFD93D) : const Color(0xFFB0B0C0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const SizedBox(
                  height: 44,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFD93D)),
                  ),
                ),
                error: (err, _) => const SizedBox(
                  height: 44,
                  child: Text("Failed to load categories", style: TextStyle(color: Color(0xFFB0B0C0))),
                ),
              ),
            ),

            // Meals List
            Expanded(
              child: mealsAsync.when(
                data: (meals) {
                  var filteredMeals = meals;

                  categoriesAsync.whenData((categories) {
                    if (selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.length) {
                      final selectedCategory = categories[selectedCategoryIndex - 1].category;
                      filteredMeals = meals
                          .where((meal) => meal.category == selectedCategory)
                          .toList();
                    } else if (selectedCategoryIndex == 0) {
                      filteredMeals = meals;
                    } else {
                      filteredMeals = [];
                    }
                  });

                  if (filteredMeals.isEmpty) {
                    return const Center(
                      child: Text(
                        "No recipes found",
                        style: TextStyle(color: Color(0xFFB0B0C0), fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filteredMeals.length,
                    itemBuilder: (context, index) {
                      return _buildMealCard(context, filteredMeals[index]);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFFD93D)),
                ),
                error: (err, _) => Center(
                  child: Text(
                    "Error loading meals: $err",
                    style: const TextStyle(color: Color(0xFFB0B0C0)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Meal meal) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MealDetailScreen(meal: meal)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A2A3E),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  Image.network(
                    meal.image ?? '',
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 110,
                      height: 110,
                      color: const Color(0xFF0F0F1E),
                      child: const Icon(Icons.fastfood, color: Color(0xFFFFD93D), size: 40),
                    ),
                  ),
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      meal.name ?? 'Unnamed',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFFD93D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6BCB77).withOpacity(0.2),
                        border: Border.all(color: const Color(0xFF6BCB77), width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        meal.category ?? 'General',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6BCB77),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: const Color(0xFF2A2A3E)),
            ),
          ],
        ),
      ),
    );
  }
}