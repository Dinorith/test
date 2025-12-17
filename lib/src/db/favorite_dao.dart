import 'package:floor/floor.dart';
import 'favorite_entity.dart';

@dao
abstract class FavoriteDao {
  @Query('SELECT * FROM FavoriteMeal')
  Future<List<FavoriteMeal>> findAllFavorites();

  @Query('SELECT * FROM FavoriteMeal WHERE id = :id')
  Future<FavoriteMeal?> findFavoriteById(int id);

  @insert
  Future<void> insertFavorite(FavoriteMeal meal);

  @delete
  Future<void> deleteFavorite(FavoriteMeal meal);
}
