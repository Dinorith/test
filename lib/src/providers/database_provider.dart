import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../db/app_database.dart';

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  return db;
});
