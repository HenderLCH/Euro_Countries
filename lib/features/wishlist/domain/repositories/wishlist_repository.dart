import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';

abstract class WishlistRepository {

  Stream<WishlistChangeEvent> get wishlistChanges;
  Future<List<WishlistItem>> getWishlistItems();
  Future<void> addToWishlist(WishlistItem item);
  Future<void> removeFromWishlist(String countryId);
  Future<bool> isInWishlist(String countryId);
  Future<void> clearWishlist();
  Future<int> getWishlistCount();
  Future<Map<String, bool>> batchCheckWishlistStatus(List<String> countryIds);
  Future<void> addAllStressTest(List<WishlistItem> items);

}

enum WishlistChangeType { added, removed, cleared }

class WishlistChangeEvent {

  const WishlistChangeEvent({
    required this.type,
    required this.countryId,

  });

  final WishlistChangeType type;
  final String countryId;
  
}