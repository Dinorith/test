import 'package:floor/floor.dart';

@entity
class FavoriteMeal {
  @primaryKey
  final int id; // Keep as int for database
  final String name;
  final String image;
  final String category;
  final String area;

  FavoriteMeal(
    this.id,
    this.name,
    this.image,
    this.category,
    this.area,
  );
}
