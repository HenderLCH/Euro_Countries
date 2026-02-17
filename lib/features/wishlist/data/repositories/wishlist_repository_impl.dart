import 'dart:async';
import 'package:euro_list/features/wishlist/data/datasources/app_database.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';

//Repositorio para la wishlist 

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({required AppDatabase database}) 
      : _database = database;

  final AppDatabase _database;
  final StreamController<WishlistChangeEvent> _changeController = 
      StreamController<WishlistChangeEvent>.broadcast();

  @override
  Stream<WishlistChangeEvent> get wishlistChanges => _changeController.stream;

//Obtener los paises de la wishlist 

  @override
  Future<List<WishlistItem>> getWishlistItems() async {
    final dtoList = await _database.getAllWishlistItems();
    return dtoList.map((dto) => WishlistItem(
      id: dto.id,
      name: dto.name,
      flagUrl: dto.flagUrl,
      addedAt: dto.addedAt,
    )).toList();
  }

//Agregar un pais a la wishlist 

  @override
  Future<void> addToWishlist(WishlistItem item) async {
    final dto = WishlistItemData(
      id: item.id,
      name: item.name,
      flagUrl: item.flagUrl,
      addedAt: item.addedAt,
    );
    await _database.addToWishlist(dto);
    _changeController.add(WishlistChangeEvent(
      type: WishlistChangeType.added,
      countryId: item.id,
    ));
  }

//Eliminar uun pais de la wishlist 

  @override
  Future<void> removeFromWishlist(String countryId) async {
    await _database.removeFromWishlist(countryId);
    _changeController.add(WishlistChangeEvent(
      type: WishlistChangeType.removed,
      countryId: countryId,
    ));
  }

// Validar si un pais esta en la wishlist
  @override
  Future<bool> isInWishlist(String countryId) async {
    return await _database.isInWishlist(countryId);
  }

//Limpiar la wishlist 

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

//Agregar todos los paises para el Stress Test

  @override
  Future<void> addAllStressTest(List<WishlistItem> items) async {
    final dtoItems = items.map((item) => WishlistItemData(
      id: item.id,
      name: item.name,
      flagUrl: item.flagUrl,
      addedAt: item.addedAt,
    )).toList();
    
    const chunkSize = 100;
    for (var i = 0; i < dtoItems.length; i += chunkSize) {
      final end = (i + chunkSize < dtoItems.length) ? i + chunkSize : dtoItems.length;
      final chunk = dtoItems.sublist(i, end);
      await _database.batchInsertWishlistItems(chunk);
      
      if (i + chunkSize < dtoItems.length) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  void dispose() {
    _changeController.close();
  }
}