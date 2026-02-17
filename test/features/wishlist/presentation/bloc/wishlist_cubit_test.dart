import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/wishlist/domain/usecases/manage_wishlist.dart';
import 'package:euro_list/features/wishlist/presentation/bloc/wishlist_cubit.dart';

// Mocks
class MockGetWishlistItems extends Mock implements GetWishlistItems {}
class MockRemoveFromWishlist extends Mock implements RemoveFromWishlist {}
class MockClearWishlist extends Mock implements ClearWishlist {}
class MockPerformWishlistStressTest extends Mock implements PerformWishlistStressTest {}
class MockWishlistRepository extends Mock implements WishlistRepository {}

// Fake
class FakeWishlistItem extends Fake implements WishlistItem {}

void main() {
  late WishlistCubit cubit;
  late MockGetWishlistItems mockGetWishlistItems;
  late MockRemoveFromWishlist mockRemoveFromWishlist;
  late MockClearWishlist mockClearWishlist;
  late MockPerformWishlistStressTest mockPerformStressTest;
  late MockWishlistRepository mockWishlistRepository;
  late StreamController<WishlistChangeEvent> wishlistStreamController;

  setUpAll(() {
    registerFallbackValue(FakeWishlistItem());
  });

  setUp(() {
    mockGetWishlistItems = MockGetWishlistItems();
    mockRemoveFromWishlist = MockRemoveFromWishlist();
    mockClearWishlist = MockClearWishlist();
    mockPerformStressTest = MockPerformWishlistStressTest();
    mockWishlistRepository = MockWishlistRepository();

    // Create a stream controller for wishlist changes
    wishlistStreamController = StreamController<WishlistChangeEvent>.broadcast();

    // Mock the wishlist changes stream
    when(() => mockWishlistRepository.wishlistChanges)
        .thenAnswer((_) => wishlistStreamController.stream);

    cubit = WishlistCubit(
      getWishlistItems: mockGetWishlistItems,
      removeFromWishlist: mockRemoveFromWishlist,
      clearWishlist: mockClearWishlist,
      performStressTest: mockPerformStressTest,
      wishlistRepository: mockWishlistRepository,
    );
  });

  tearDown(() {
    wishlistStreamController.close();
    cubit.close();
  });

  group('WishlistCubit', () {
    final tItems = [
      WishlistItem(
        id: 'ESP',
        name: 'Spain',
        flagUrl: 'https://flagcdn.com/es.svg',
        addedAt: DateTime(2024, 1, 15),
      ),
      WishlistItem(
        id: 'FRA',
        name: 'France',
        flagUrl: 'https://flagcdn.com/fr.svg',
        addedAt: DateTime(2024, 1, 16),
      ),
    ];

    test('initial state should be WishlistInitial', () {
      expect(cubit.state, const WishlistInitial());
    });

    group('loadWishlist', () {
      blocTest<WishlistCubit, WishlistState>(
        'emits [WishlistLoading, WishlistLoaded] when loadWishlist succeeds',
        build: () {
          when(() => mockGetWishlistItems()).thenAnswer((_) async => tItems);
          return cubit;
        },
        act: (cubit) => cubit.loadWishlist(),
        expect: () => [
          const WishlistLoading(),
          WishlistLoaded(items: tItems),
        ],
        verify: (_) {
          verify(() => mockGetWishlistItems()).called(1);
        },
      );

      blocTest<WishlistCubit, WishlistState>(
        'emits [WishlistLoading, WishlistError] when loadWishlist fails',
        build: () {
          when(() => mockGetWishlistItems())
              .thenThrow(Exception('Database error'));
          return cubit;
        },
        act: (cubit) => cubit.loadWishlist(),
        expect: () => [
          const WishlistLoading(),
          const WishlistError(message: 'Exception: Database error'),
        ],
      );

      blocTest<WishlistCubit, WishlistState>(
        'emits loaded state with empty list when no items',
        build: () {
          when(() => mockGetWishlistItems()).thenAnswer((_) async => []);
          return cubit;
        },
        act: (cubit) => cubit.loadWishlist(),
        expect: () => [
          const WishlistLoading(),
          const WishlistLoaded(items: []),
        ],
      );
    });

    group('removeItem', () {
      blocTest<WishlistCubit, WishlistState>(
        'removes item from wishlist when in loaded state',
        build: () {
          when(() => mockRemoveFromWishlist('ESP')).thenAnswer((_) async {});
          return cubit;
        },
        seed: () => WishlistLoaded(items: tItems),
        act: (cubit) => cubit.removeItem('ESP'),
        expect: () => [
          WishlistLoaded(items: [tItems[1]]), // Solo queda Francia
        ],
        verify: (_) {
          verify(() => mockRemoveFromWishlist('ESP')).called(1);
        },
      );

      blocTest<WishlistCubit, WishlistState>(
        'emits error when remove fails',
        build: () {
          when(() => mockRemoveFromWishlist('ESP'))
              .thenThrow(Exception('Remove failed'));
          return cubit;
        },
        seed: () => WishlistLoaded(items: tItems),
        act: (cubit) => cubit.removeItem('ESP'),
        expect: () => [
          const WishlistError(message: 'Failed to remove item: Exception: Remove failed'),
          WishlistLoaded(items: tItems), // Restaura estado
        ],
      );

      blocTest<WishlistCubit, WishlistState>(
        'does nothing when state is not loaded',
        build: () => cubit,
        act: (cubit) => cubit.removeItem('ESP'),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRemoveFromWishlist(any()));
        },
      );
    });

    group('clearWishlist', () {
      blocTest<WishlistCubit, WishlistState>(
        'clears all items from wishlist',
        build: () {
          when(() => mockClearWishlist()).thenAnswer((_) async {});
          return cubit;
        },
        act: (cubit) => cubit.clearWishlist(),
        expect: () => [
          const WishlistLoaded(items: []),
        ],
        verify: (_) {
          verify(() => mockClearWishlist()).called(1);
        },
      );

      blocTest<WishlistCubit, WishlistState>(
        'emits error when clear fails',
        build: () {
          when(() => mockClearWishlist())
              .thenThrow(Exception('Clear failed'));
          return cubit;
        },
        act: (cubit) => cubit.clearWishlist(),
        expect: () => [
          const WishlistError(message: 'Failed to clear wishlist: Exception: Clear failed'),
        ],
      );
    });

    group('runStressTest', () {
      blocTest<WishlistCubit, WishlistState>(
        'emits [Running, Completed] when stress test succeeds',
        build: () {
          when(() => mockPerformStressTest()).thenAnswer((_) async {});
          when(() => mockGetWishlistItems()).thenAnswer((_) async => tItems);
          return cubit;
        },
        act: (cubit) => cubit.runStressTest(),
        expect: () => [
          const WishlistStressTestRunning(),
          isA<WishlistStressTestCompleted>()
              .having((s) => s.items, 'items', tItems)
              .having((s) => s.duration, 'duration', isA<Duration>()),
        ],
        verify: (_) {
          verify(() => mockPerformStressTest()).called(1);
          verify(() => mockGetWishlistItems()).called(1);
        },
      );

      blocTest<WishlistCubit, WishlistState>(
        'emits error when stress test fails',
        build: () {
          when(() => mockPerformStressTest())
              .thenThrow(Exception('Stress test failed'));
          return cubit;
        },
        act: (cubit) => cubit.runStressTest(),
        expect: () => [
          const WishlistStressTestRunning(),
          const WishlistError(message: 'Stress test failed: Exception: Stress test failed'),
        ],
      );
    });

    group('refresh', () {
      blocTest<WishlistCubit, WishlistState>(
        'calls loadWishlist when refresh is called',
        build: () {
          when(() => mockGetWishlistItems()).thenAnswer((_) async => tItems);
          return cubit;
        },
        act: (cubit) => cubit.refresh(),
        expect: () => [
          const WishlistLoading(),
          WishlistLoaded(items: tItems),
        ],
      );
    });
  });
}
