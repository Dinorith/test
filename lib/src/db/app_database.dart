import 'dart:async';
import 'package:floor/floor.dart';
import 'favorite_entity.dart';
import 'favorite_dao.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart';

@Database(version: 1, entities: [FavoriteMeal])
abstract class AppDatabase extends FloorDatabase {
  FavoriteDao get favoriteDao;
}
