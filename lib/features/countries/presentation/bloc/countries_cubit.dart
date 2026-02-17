import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/countries/domain/usecases/get_european_countries.dart';
import 'package:euro_list/features/wishlist/domain/usecases/manage_wishlist.dart';
import 'package:euro_list/features/countries/presentation/bloc/countries_state.dart';

  //BloC para  obtener los paises europeos y el estado de la wishlist

class CountriesCubit extends Cubit<CountriesState> {
  CountriesCubit({
    required this.getEuropeanCountries,
    required this.batchCheckWishlistStatus,
    required this.addToWishlist,
    required this.removeFromWishlist,
    required this.wishlistRepository,
  }) : super(CountriesInitial()) {
    _wishlistSubscription = wishlistRepository.wishlistChanges.listen(_onWishlistChanged);
  }

  final GetEuropeanCountries getEuropeanCountries;
  final BatchCheckWishlistStatus batchCheckWishlistStatus;
  final AddToWishlist addToWishlist;
  final RemoveFromWishlist removeFromWishlist;
  final WishlistRepository wishlistRepository;

  StreamSubscription<WishlistChangeEvent>? _wishlistSubscription;

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

      // Actualizar el estado de la wishlist
      final updatedStatus = Map<String, bool>.from(currentState.wishlistStatus);
      updatedStatus[countryId] = !isInWishlist;
      
      emit(CountriesLoaded(
        countries: currentState.countries,
        wishlistStatus: updatedStatus,
      ));
    }
  }

  void _onWishlistChanged(WishlistChangeEvent event) {
    final currentState = state;
    if (currentState is CountriesLoaded) {
      final updatedStatus = Map<String, bool>.from(currentState.wishlistStatus);
      
      switch (event.type) {
        case WishlistChangeType.added:
          updatedStatus[event.countryId] = true;
          break;
        case WishlistChangeType.removed:
          updatedStatus[event.countryId] = false;
          break;
        case WishlistChangeType.cleared:
          for (final key in updatedStatus.keys) {
            updatedStatus[key] = false;
          }
          break;
      }
      
      emit(CountriesLoaded(
        countries: currentState.countries,
        wishlistStatus: updatedStatus,
      ));
    }
  }

  @override
  Future<void> close() {
    _wishlistSubscription?.cancel();
    return super.close();
  }
}