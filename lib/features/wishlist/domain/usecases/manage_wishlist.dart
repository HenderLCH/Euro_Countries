import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';

class GetWishlistItems {

  const GetWishlistItems({required this.repository});

  final WishlistRepository repository;

  Future<List<WishlistItem>> call() async {

    return await repository.getWishlistItems();
  
  }

}

class AddToWishlist {

  const AddToWishlist({required this.repository});
  final WishlistRepository repository;

  Future<void> call(WishlistItem item) async {

    return await repository.addToWishlist(item);
  
  }

}

class RemoveFromWishlist {

  const RemoveFromWishlist({required this.repository});
  final WishlistRepository repository;

  Future<void> call(String countryId) async {
    
    return await repository.removeFromWishlist(countryId);
  
  }

}

class IsInWishlist {

  const IsInWishlist({required this.repository});
  final WishlistRepository repository;

  Future<bool> call(String countryId) async {

    return await repository.isInWishlist(countryId);
  
  }

}

class BatchCheckWishlistStatus {

  const BatchCheckWishlistStatus({required this.repository});
  final WishlistRepository repository;

  Future<Map<String, bool>> call(List<String> countryIds) async {
    
    return await repository.batchCheckWishlistStatus(countryIds);
  
  }

}

class ClearWishlist {

  const ClearWishlist({required this.repository});
  final WishlistRepository repository;

  Future<void> call() async {

    return await repository.clearWishlist();
  
  }

}

class PerformWishlistStressTest {

  const PerformWishlistStressTest({required this.repository});
  final WishlistRepository repository;

  Future<void> call() async {
    // Este use case se encarga de ejecutar el stress test
    // agregando todos los países europeos a la wishlist
    
    // Crear items de prueba (simulando todos los países europeos)
    final testItems = List.generate(50, (index) => WishlistItem(
      id: 'STRESS_TEST_$index',
      name: 'Test Country $index',
      flagUrl: 'https://flagcdn.com/w320/eu.png',
      addedAt: DateTime.now(),
    ));

    return await repository.addAllStressTest(testItems);
  
  }

} 