import 'package:euro_list/features/countries/data/datasources/restcountries_api.dart';
import 'package:euro_list/features/countries/data/repositories/countries_repository_impl.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';
import 'package:euro_list/features/countries/domain/usecases/get_country_details.dart';
import 'package:euro_list/features/countries/domain/usecases/get_european_countries.dart';
import 'package:euro_list/features/countries/presentation/bloc/countries_cubit.dart';
import 'package:euro_list/features/countries/presentation/bloc/country_detail_cubit.dart';
import 'package:euro_list/features/wishlist/data/datasources/app_database.dart';
import 'package:euro_list/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/wishlist/domain/usecases/manage_wishlist.dart';
import 'package:euro_list/features/wishlist/presentation/bloc/wishlist_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  final api = RestCountriesApi();
  final database = AppDatabase();

  sl
    ..registerLazySingleton<RestCountriesApi>(() => api)
    ..registerLazySingleton<AppDatabase>(() => database)

    // Repositories
    ..registerLazySingleton<CountryRepository>(
      () => CountryRepositoryImpl(api: sl()),
    )
    ..registerLazySingleton<WishlistRepository>(
      () => WishlistRepositoryImpl(database: sl()),
    )

    // Use cases - Countries
    ..registerLazySingleton(() => GetEuropeanCountries(repository: sl()))
    ..registerLazySingleton(() => GetCountryDetails(repository: sl()))
    
    // Use cases - Wishlist
    ..registerLazySingleton(() => GetWishlistItems(repository: sl()))
    ..registerLazySingleton(() => AddToWishlist(repository: sl()))
    ..registerLazySingleton(() => RemoveFromWishlist(repository: sl()))
    ..registerLazySingleton(() => ClearWishlist(repository: sl()))
    ..registerLazySingleton(() => IsInWishlist(repository: sl()))
    ..registerLazySingleton(() => BatchCheckWishlistStatus(repository: sl()))
    ..registerLazySingleton(() => PerformWishlistStressTest(
      wishlistRepository: sl(),
      countryRepository: sl(),
    ))

    // BLoCs (factories para crear nueva instancia cada vez)
    ..registerFactory(
      () => CountriesCubit(
        getEuropeanCountries: sl(),
        batchCheckWishlistStatus: sl(),
        addToWishlist: sl(),
        removeFromWishlist: sl(),
        wishlistRepository: sl(),
      ),
    )
    ..registerFactory(
      () => CountryDetailCubit(
        getCountryDetails: sl(),
        isInWishlist: sl(),
        addToWishlist: sl(),
        removeFromWishlist: sl(),
        wishlistRepository: sl(),
      ),
    )
    ..registerFactory(
      () => WishlistCubit(
        getWishlistItems: sl(),
        removeFromWishlist: sl(),
        clearWishlist: sl(),
        performStressTest: sl(),
        wishlistRepository: sl(),
      ),
    );
}