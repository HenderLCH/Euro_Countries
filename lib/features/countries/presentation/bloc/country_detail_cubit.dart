import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:euro_list/features/countries/domain/usecases/get_country_details.dart';
import 'package:euro_list/features/wishlist/domain/usecases/manage_wishlist.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/countries/presentation/bloc/country_detail_state.dart';

class CountryDetailCubit extends Cubit<CountryDetailState> {
  CountryDetailCubit({
    required this.getCountryDetails,
    required this.isInWishlist,
    required this.addToWishlist,
    required this.removeFromWishlist,
    required this.wishlistRepository,
  }) : super(CountryDetailInitial());

  final GetCountryDetails getCountryDetails;
  final IsInWishlist isInWishlist;
  final AddToWishlist addToWishlist;
  final RemoveFromWishlist removeFromWishlist;
  final WishlistRepository wishlistRepository;

  StreamSubscription<WishlistChangeEvent>? _wishlistSubscription;

  Future<void> loadCountryDetail(String countryName) async {
    emit(CountryDetailLoading());
    try {
      final country = await getCountryDetails(countryName);
      final inWishlist = await isInWishlist(country.id);
      
      emit(CountryDetailLoaded(
        country: country,
        isInWishlist: inWishlist,
      ));

      _wishlistSubscription = wishlistRepository.wishlistChanges.listen((event) {
        final currentState = state;
        if (currentState is CountryDetailLoaded) {
          if (event.countryId == currentState.country.id) {
            emit(currentState.copyWith(
              isInWishlist: event.type == WishlistChangeType.added,
            ));
          }
        }
      });
    } catch (e) {
      emit(CountryDetailError(e.toString()));
    }
  }

  Future<void> toggleWishlist() async {
    final currentState = state;
    if (currentState is CountryDetailLoaded) {
      final country = currentState.country;
      final isCurrentlyInWishlist = currentState.isInWishlist;

      if (isCurrentlyInWishlist) {
        await removeFromWishlist(country.id);
      } else {
        await addToWishlist(WishlistItem(
          id: country.id,
          name: country.name,
          flagUrl: country.flagUrl,
          addedAt: DateTime.now(),
        ));
      }

      emit(currentState.copyWith(isInWishlist: !isCurrentlyInWishlist));
    }
  }

  @override
  Future<void> close() {
    _wishlistSubscription?.cancel();
    return super.close();
  }
}
