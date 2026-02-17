import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:euro_list/features/wishlist/data/datasources/app_database.dart';
import 'package:euro_list/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late WishlistRepositoryImpl repository;
  late MockAppDatabase mockDatabase;

  setUpAll(() {
    registerFallbackValue(
      WishlistItem(
        id: 'test',
        name: 'Test',
        flagUrl: 'test.svg',
        addedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockDatabase = MockAppDatabase();
    repository = WishlistRepositoryImpl(database: mockDatabase);
  });

  tearDown(() {
    repository.dispose();
  });

  group('WishlistRepositoryImpl', () {
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

    group('getWishlistItems', () {
      test('should return list of items from database', () async {
        // Arrange
        when(() => mockDatabase.getAllWishlistItems())
            .thenAnswer((_) async => tItems);

        // Act
        final result = await repository.getWishlistItems();

        // Assert
        expect(result, equals(tItems));
        expect(result.length, 2);
        verify(() => mockDatabase.getAllWishlistItems()).called(1);
      });

      test('should return empty list when database is empty', () async {
        // Arrange
        when(() => mockDatabase.getAllWishlistItems())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getWishlistItems();

        // Assert
        expect(result, isEmpty);
        verify(() => mockDatabase.getAllWishlistItems()).called(1);
      });
    });

    group('addToWishlist', () {
      test('should add item to database and emit change event', () async {
        // Arrange
        final tItem = tItems.first;
        when(() => mockDatabase.addToWishlist(any()))
            .thenAnswer((_) async {});

        // Listen to stream
        final events = <dynamic>[];
        repository.wishlistChanges.listen(events.add);

        // Act
        await repository.addToWishlist(tItem);

        // Assert
        verify(() => mockDatabase.addToWishlist(tItem)).called(1);
        
        // Wait for stream event
        await Future.delayed(const Duration(milliseconds: 100));
        expect(events.length, 1);
        expect(events.first.countryId, 'ESP');
      });
    });

    group('removeFromWishlist', () {
      test('should remove item from database and emit change event', () async {
        // Arrange
        const tCountryId = 'ESP';
        when(() => mockDatabase.removeFromWishlist(tCountryId))
            .thenAnswer((_) async {});

        // Listen to stream
        final events = <dynamic>[];
        repository.wishlistChanges.listen(events.add);

        // Act
        await repository.removeFromWishlist(tCountryId);

        // Assert
        verify(() => mockDatabase.removeFromWishlist(tCountryId)).called(1);
        
        // Wait for stream event
        await Future.delayed(const Duration(milliseconds: 100));
        expect(events.length, 1);
        expect(events.first.countryId, 'ESP');
      });
    });

    group('isInWishlist', () {
      test('should return true when item is in database', () async {
        // Arrange
        const tCountryId = 'ESP';
        when(() => mockDatabase.isInWishlist(tCountryId))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.isInWishlist(tCountryId);

        // Assert
        expect(result, isTrue);
        verify(() => mockDatabase.isInWishlist(tCountryId)).called(1);
      });

      test('should return false when item is not in database', () async {
        // Arrange
        const tCountryId = 'ESP';
        when(() => mockDatabase.isInWishlist(tCountryId))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.isInWishlist(tCountryId);

        // Assert
        expect(result, isFalse);
        verify(() => mockDatabase.isInWishlist(tCountryId)).called(1);
      });
    });

    group('clearWishlist', () {
      test('should clear database and emit change event', () async {
        // Arrange
        when(() => mockDatabase.clearWishlist()).thenAnswer((_) async {});

        // Listen to stream
        final events = <dynamic>[];
        repository.wishlistChanges.listen(events.add);

        // Act
        await repository.clearWishlist();

        // Assert
        verify(() => mockDatabase.clearWishlist()).called(1);
        
        // Wait for stream event
        await Future.delayed(const Duration(milliseconds: 100));
        expect(events.length, 1);
      });
    });

    group('getWishlistCount', () {
      test('should return count from database', () async {
        // Arrange
        when(() => mockDatabase.getWishlistCount())
            .thenAnswer((_) async => 5);

        // Act
        final result = await repository.getWishlistCount();

        // Assert
        expect(result, 5);
        verify(() => mockDatabase.getWishlistCount()).called(1);
      });
    });

    group('batchCheckWishlistStatus', () {
      test('should return status map from database', () async {
        // Arrange
        final tCountryIds = ['ESP', 'FRA', 'ITA'];
        final tStatus = {
          'ESP': true,
          'FRA': false,
          'ITA': false,
        };

        when(() => mockDatabase.batchCheckWishlistStatus(tCountryIds))
            .thenAnswer((_) async => tStatus);

        // Act
        final result = await repository.batchCheckWishlistStatus(tCountryIds);

        // Assert
        expect(result, equals(tStatus));
        expect(result['ESP'], isTrue);
        expect(result['FRA'], isFalse);
        verify(() => mockDatabase.batchCheckWishlistStatus(tCountryIds)).called(1);
      });
    });

    group('addAllStressTest', () {
      test('should process items in chunks to prevent janks', () async {
        // Arrange - Crear muchos items para probar chunking
        final tItems = List.generate(
          250, // Más de 2 chunks (100 items cada uno)
          (index) => WishlistItem(
            id: 'COUNTRY_$index',
            name: 'Country $index',
            flagUrl: 'https://flag.url/$index.png',
            addedAt: DateTime.now(),
          ),
        );

        when(() => mockDatabase.batchInsertWishlistItems(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.addAllStressTest(tItems);

        // Assert
        // Debería llamar 3 veces (250 items / 100 chunk size = 3 chunks)
        verify(() => mockDatabase.batchInsertWishlistItems(any())).called(3);
      });

      test('should handle single chunk efficiently', () async {
        // Arrange - Menos de 100 items (1 solo chunk)
        final tItems = List.generate(
          50,
          (index) => WishlistItem(
            id: 'COUNTRY_$index',
            name: 'Country $index',
            flagUrl: 'https://flag.url/$index.png',
            addedAt: DateTime.now(),
          ),
        );

        when(() => mockDatabase.batchInsertWishlistItems(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.addAllStressTest(tItems);

        // Assert
        // Debería llamar 1 vez (1 chunk)
        verify(() => mockDatabase.batchInsertWishlistItems(any())).called(1);
      });

      test('should handle empty list gracefully', () async {
        // Arrange
        final tItems = <WishlistItem>[];

        when(() => mockDatabase.batchInsertWishlistItems(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.addAllStressTest(tItems);

        // Assert
        verifyNever(() => mockDatabase.batchInsertWishlistItems(any()));
      });
    });
  });
}
