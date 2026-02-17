import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/usecases/get_european_countries.dart';
import 'package:euro_list/features/countries/presentation/bloc/countries_cubit.dart';
import 'package:euro_list/features/countries/presentation/bloc/countries_state.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/wishlist/domain/usecases/manage_wishlist.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';

// Mocks
class MockGetEuropeanCountries extends Mock implements GetEuropeanCountries {}
class MockBatchCheckWishlistStatus extends Mock implements BatchCheckWishlistStatus {}
class MockAddToWishlist extends Mock implements AddToWishlist {}
class MockRemoveFromWishlist extends Mock implements RemoveFromWishlist {}
class MockWishlistRepository extends Mock implements WishlistRepository {}

// Fake para WishlistItem
class FakeWishlistItem extends Fake implements WishlistItem {}

void main() {
  setUpAll(() {
    // Registrar fallback value para WishlistItem
    registerFallbackValue(FakeWishlistItem());
  });
  late CountriesCubit cubit;
  late MockGetEuropeanCountries mockGetEuropeanCountries;
  late MockBatchCheckWishlistStatus mockBatchCheckWishlistStatus;
  late MockAddToWishlist mockAddToWishlist;
  late MockRemoveFromWishlist mockRemoveFromWishlist;
  late MockWishlistRepository mockWishlistRepository;

  setUp(() {
    mockGetEuropeanCountries = MockGetEuropeanCountries();
    mockBatchCheckWishlistStatus = MockBatchCheckWishlistStatus();
    mockAddToWishlist = MockAddToWishlist();
    mockRemoveFromWishlist = MockRemoveFromWishlist();
    mockWishlistRepository = MockWishlistRepository();

    when(() => mockWishlistRepository.wishlistChanges).thenAnswer(
      (_) => const Stream.empty(),
    );

    cubit = CountriesCubit(
      getEuropeanCountries: mockGetEuropeanCountries,
      batchCheckWishlistStatus: mockBatchCheckWishlistStatus,
      addToWishlist: mockAddToWishlist,
      removeFromWishlist: mockRemoveFromWishlist,
      wishlistRepository: mockWishlistRepository,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('CountriesCubit', () {
    final tCountries = [
      const Country(
        id: 'ESP',
        name: 'Spain',
        capital: 'Madrid',
        population: 47000000,
        region: 'Europe',
        flagUrl: 'https://flag.url/spain.png',
      ),
      const Country(
        id: 'FRA',
        name: 'France',
        capital: 'Paris',
        population: 67000000,
        region: 'Europe',
        flagUrl: 'https://flag.url/france.png',
      ),
    ];

    final tWishlistStatus = {'ESP': false, 'FRA': false};

    test('initial state should be CountriesInitial', () {
      expect(cubit.state, CountriesInitial());
    });

    group('loadCountries', () {
      blocTest<CountriesCubit, CountriesState>(
        'emits [CountriesLoading, CountriesLoaded] when loadCountries succeeds',
        build: () {
          when(() => mockGetEuropeanCountries()).thenAnswer(
            (_) async => tCountries,
          );
          when(() => mockBatchCheckWishlistStatus(['ESP', 'FRA'])).thenAnswer(
            (_) async => tWishlistStatus,
          );
          return cubit;
        },
        act: (cubit) => cubit.loadCountries(),
        expect: () => [
          CountriesLoading(),
          CountriesLoaded(
            countries: tCountries,
            wishlistStatus: tWishlistStatus,
          ),
        ],
        verify: (_) {
          verify(() => mockGetEuropeanCountries()).called(1);
          verify(() => mockBatchCheckWishlistStatus(['ESP', 'FRA'])).called(1);
        },
      );

      blocTest<CountriesCubit, CountriesState>(
        'emits [CountriesLoading, CountriesError] when loadCountries fails',
        build: () {
          when(() => mockGetEuropeanCountries()).thenThrow(
            Exception('Failed to load countries'),
          );
          return cubit;
        },
        act: (cubit) => cubit.loadCountries(),
        expect: () => [
          CountriesLoading(),
          const CountriesError('Exception: Failed to load countries'),
        ],
      );
    });

    group('toggleWishlist', () {
      setUp(() {
        when(() => mockAddToWishlist(any())).thenAnswer((_) async {});
        when(() => mockRemoveFromWishlist(any())).thenAnswer((_) async {});
      });

      blocTest<CountriesCubit, CountriesState>(
        'adds country to wishlist when not in wishlist',
        build: () => cubit,
        seed: () => CountriesLoaded(
          countries: tCountries,
          wishlistStatus: {'ESP': false, 'FRA': false},
        ),
        act: (cubit) => cubit.toggleWishlist('ESP', 'Spain', 'https://flag.url/spain.png'),
        expect: () => [
          CountriesLoaded(
            countries: tCountries,
            wishlistStatus: {'ESP': true, 'FRA': false},
          ),
        ],
        verify: (_) {
          verify(() => mockAddToWishlist(any())).called(1);
        },
      );

      blocTest<CountriesCubit, CountriesState>(
        'removes country from wishlist when already in wishlist',
        build: () => cubit,
        seed: () => CountriesLoaded(
          countries: tCountries,
          wishlistStatus: {'ESP': true, 'FRA': false},
        ),
        act: (cubit) => cubit.toggleWishlist('ESP', 'Spain', 'https://flag.url/spain.png'),
        expect: () => [
          CountriesLoaded(
            countries: tCountries,
            wishlistStatus: {'ESP': false, 'FRA': false},
          ),
        ],
        verify: (_) {
          verify(() => mockRemoveFromWishlist('ESP')).called(1);
        },
      );

      blocTest<CountriesCubit, CountriesState>(
        'does nothing when state is not CountriesLoaded',
        build: () => cubit,
        act: (cubit) => cubit.toggleWishlist('ESP', 'Spain', 'https://flag.url/spain.png'),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockAddToWishlist(any()));
          verifyNever(() => mockRemoveFromWishlist(any()));
        },
      );
    });
  });
}

