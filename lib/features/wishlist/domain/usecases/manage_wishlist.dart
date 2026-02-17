import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';

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

  const PerformWishlistStressTest({
    required this.wishlistRepository,
    required this.countryRepository,
  });
  
  final WishlistRepository wishlistRepository;
  final CountryRepository countryRepository;

  Future<void> call() async {
    // Obtener todos los países europeos reales de la API
    final countries = await countryRepository.getEuropeanCountries();
    
    // Convertir los países a WishlistItems
    final wishlistItems = countries.map((country) => WishlistItem(
      id: country.id,
      name: country.name,
      flagUrl: country.flagUrl,
      addedAt: DateTime.now(),
    )).toList();

    // Agregar todos los países en lotes (anti-janks)
    return await wishlistRepository.addAllStressTest(wishlistItems);
  
  }

} 