import 'dart:async';
import 'package:euro_list/features/wishlist/data/datasources/app_database.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({required AppDatabase database}) 
      : _database = database;

  final AppDatabase _database;
  final StreamController<WishlistChangeEvent> _changeController = 
      StreamController<WishlistChangeEvent>.broadcast();

  @override
  Stream<WishlistChangeEvent> get wishlistChanges => _changeController.stream;

  @override
  Future<List<WishlistItem>> getWishlistItems() async {
    return await _database.getAllWishlistItems();
  }

  @override
  Future<void> addToWishlist(WishlistItem item) async {
    await _database.addToWishlist(item);
    _changeController.add(WishlistChangeEvent(
      type: WishlistChangeType.added,
      countryId: item.id,
    ));
  }

  @override
  Future<void> removeFromWishlist(String countryId) async {
    await _database.removeFromWishlist(countryId);
    _changeController.add(WishlistChangeEvent(
      type: WishlistChangeType.removed,
      countryId: countryId,
    ));
  }

  @override
  Future<bool> isInWishlist(String countryId) async {
    return await _database.isInWishlist(countryId);
  }

  @override
  Future<void> clearWishlist() async {
    await _database.clearWishlist();
    _changeController.add(const WishlistChangeEvent(
      type: WishlistChangeType.cleared,
      countryId: '',
    ));
  }

  @override
  Future<int> getWishlistCount() async {
    return await _database.getWishlistCount();
  }

  @override
  Future<Map<String, bool>> batchCheckWishlistStatus(List<String> countryIds) async {
    return await _database.batchCheckWishlistStatus(countryIds);
  }

  @override
  Future<void> addAllStressTest(List<WishlistItem> items) async {
    // Procesar en chunks para evitar janks
    const chunkSize = 100;
    for (var i = 0; i < items.length; i += chunkSize) {
      final end = (i + chunkSize < items.length) ? i + chunkSize : items.length;
      final chunk = items.sublist(i, end);
      await _database.batchInsertWishlistItems(chunk);
      
      // Pequeño delay para no bloquear la UI
      if (i + chunkSize < items.length) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  void dispose() {
    _changeController.close();
  }
}