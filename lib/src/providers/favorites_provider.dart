import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/favorite_dao.dart';
import '../db/favorite_entity.dart';
import 'database_provider.dart';

class FavoritesNotifier extends StateNotifier<List<FavoriteMeal>> {
  final FavoriteDao dao;

  FavoritesNotifier(this.dao) : super([]) {
    load();
  }

  Future<void> load() async {
    state = await dao.findAllFavorites();
  }

  Future<void> add(FavoriteMeal meal) async {
    await dao.insertFavorite(meal);
    await load();
  }

  Future<void> remove(FavoriteMeal meal) async {
    await dao.deleteFavorite(meal);
    await load();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<FavoriteMeal>>((ref) {
  final db = ref.watch(databaseProvider).value;
  final dao = db!.favoriteDao;
  return FavoritesNotifier(dao);
});
