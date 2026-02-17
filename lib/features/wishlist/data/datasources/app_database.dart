import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('WishlistItemData')
class WishlistItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get flagUrl => text()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [WishlistItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  Future<List<WishlistItemData>> getAllWishlistItems() async {
    return await select(wishlistItems).get();
  }

  Future<void> addToWishlist(WishlistItemData item) async {
    await into(wishlistItems).insertOnConflictUpdate(
      WishlistItemsCompanion(
        id: Value(item.id),
        name: Value(item.name),
        flagUrl: Value(item.flagUrl),
        addedAt: Value(item.addedAt),
      ),
    );
  }

  Future<void> removeFromWishlist(String countryId) async {
    await (delete(wishlistItems)..where((tbl) => tbl.id.equals(countryId))).go();
  }

  Future<bool> isInWishlist(String countryId) async {
    final result = await (select(wishlistItems)
      ..where((tbl) => tbl.id.equals(countryId))).getSingleOrNull();
    return result != null;
  }

  Future<void> clearWishlist() async {
    await delete(wishlistItems).go();
  }

  Future<int> getWishlistCount() async {
    final count = await (select(wishlistItems)).get();
    return count.length;
  }

  Future<void> batchInsertWishlistItems(List<WishlistItemData> items) async {
    await batch((batch) {
      batch.insertAll(
        wishlistItems,
        items.map((item) => WishlistItemsCompanion(
          id: Value(item.id),
          name: Value(item.name),
          flagUrl: Value(item.flagUrl),
          addedAt: Value(item.addedAt),
        )),
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<Map<String, bool>> batchCheckWishlistStatus(List<String> countryIds) async {
    final items = await (select(wishlistItems)
      ..where((tbl) => tbl.id.isIn(countryIds))).get();
    
    final existingIds = items.map((item) => item.id).toSet();
    return {
      for (final id in countryIds) id: existingIds.contains(id),
    };
  }
}

//Conexion a la base de datos

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wishlist.db'));
    return NativeDatabase(file);
  });
}