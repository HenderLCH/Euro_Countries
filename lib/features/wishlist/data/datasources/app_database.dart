import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// Tabla de wishlist
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
  
  // Constructor para testing (acepta una conexión en memoria)
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // Obtener todos los items de wishlist
  Future<List<WishlistItem>> getAllWishlistItems() async {
    final items = await select(wishlistItems).get();
    return items.map((item) => WishlistItem(
      id: item.id,
      name: item.name,
      flagUrl: item.flagUrl,
      addedAt: item.addedAt,
    )).toList();
  }

  // Agregar a wishlist
  Future<void> addToWishlist(WishlistItem item) async {
    await into(wishlistItems).insertOnConflictUpdate(
      WishlistItemsCompanion(
        id: Value(item.id),
        name: Value(item.name),
        flagUrl: Value(item.flagUrl),
        addedAt: Value(item.addedAt),
      ),
    );
  }

  // Remover de wishlist
  Future<void> removeFromWishlist(String countryId) async {
    await (delete(wishlistItems)..where((tbl) => tbl.id.equals(countryId))).go();
  }

  // Verificar si está en wishlist
  Future<bool> isInWishlist(String countryId) async {
    final result = await (select(wishlistItems)
      ..where((tbl) => tbl.id.equals(countryId))).getSingleOrNull();
    return result != null;
  }

  // Limpiar wishlist
  Future<void> clearWishlist() async {
    await delete(wishlistItems).go();
  }

  // Contar items
  Future<int> getWishlistCount() async {
    final count = await (select(wishlistItems)).get();
    return count.length;
  }

  // Batch insert (para stress test)
  Future<void> batchInsertWishlistItems(List<WishlistItem> items) async {
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

  // Batch check status
  Future<Map<String, bool>> batchCheckWishlistStatus(List<String> countryIds) async {
    final items = await (select(wishlistItems)
      ..where((tbl) => tbl.id.isIn(countryIds))).get();
    
    final existingIds = items.map((item) => item.id).toSet();
    return {
      for (final id in countryIds) id: existingIds.contains(id),
    };
  }
}

// Función para abrir la conexión
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wishlist.db'));
    return NativeDatabase(file);
  });
}