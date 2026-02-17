import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/countries/domain/usecases/get_european_countries.dart';
import 'package:euro_list/features/wishlist/domain/usecases/manage_wishlist.dart';
import 'package:euro_list/features/countries/presentation/bloc/countries_state.dart';

class CountriesCubit extends Cubit<CountriesState> {
  CountriesCubit({
    required this.getEuropeanCountries,
    required this.batchCheckWishlistStatus,
    required this.addToWishlist,
    required this.removeFromWishlist,
    required this.wishlistRepository,
  }) : super(CountriesInitial());

  final GetEuropeanCountries getEuropeanCountries;
  final BatchCheckWishlistStatus batchCheckWishlistStatus;
  final AddToWishlist addToWishlist;
  final RemoveFromWishlist removeFromWishlist;
  final WishlistRepository wishlistRepository;

  Future<void> loadCountries() async {
    emit(CountriesLoading());
    try {
      final countries = await getEuropeanCountries();
      final countryIds = countries.map((c) => c.id).toList();
      final wishlistStatus = await batchCheckWishlistStatus(countryIds);
      emit(CountriesLoaded(
        countries: countries,
        wishlistStatus: wishlistStatus,
      ));
    } catch (e) {
      emit(CountriesError(e.toString()));
    }
  }

  Future<void> toggleWishlist(String countryId, String name, String flagUrl) async {
    final currentState = state;
    if (currentState is CountriesLoaded) {
      final isInWishlist = currentState.wishlistStatus[countryId] ?? false;
      
      if (isInWishlist) {
        await removeFromWishlist(countryId);
      } else {
        await addToWishlist(WishlistItem(
          id: countryId,
          name: name,
          flagUrl: flagUrl,
          addedAt: DateTime.now(),
        ));
      }

      // Actualizar estado local
      final updatedStatus = Map<String, bool>.from(currentState.wishlistStatus);
      updatedStatus[countryId] = !isInWishlist;
      
      emit(CountriesLoaded(
        countries: currentState.countries,
        wishlistStatus: updatedStatus,
      ));
    }
  }
}