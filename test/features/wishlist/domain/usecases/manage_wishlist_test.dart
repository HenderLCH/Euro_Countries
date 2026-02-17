import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';
import 'package:euro_list/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:euro_list/features/wishlist/domain/usecases/manage_wishlist.dart';

class MockWishlistRepository extends Mock implements WishlistRepository {}

void main() {
  late MockWishlistRepository mockRepository;

  setUpAll(() {
    // Register fallback value for WishlistItem
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
    mockRepository = MockWishlistRepository();
  });

  group('GetWishlistItems', () {
    late GetWishlistItems usecase;

    setUp(() {
      usecase = GetWishlistItems(repository: mockRepository);
    });

    test('should return list of wishlist items from repository', () async {
      // Arrange
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

      when(() => mockRepository.getWishlistItems())
          .thenAnswer((_) async => tItems);

      // Act
      final result = await usecase();

      // Assert
      expect(result, equals(tItems));
      expect(result.length, 2);
      verify(() => mockRepository.getWishlistItems()).called(1);
    });

    test('should return empty list when repository returns empty list', () async {
      // Arrange
      when(() => mockRepository.getWishlistItems())
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase();

      // Assert
      expect(result, isEmpty);
      verify(() => mockRepository.getWishlistItems()).called(1);
    });
  });

  group('AddToWishlist', () {
    late AddToWishlist usecase;

    setUp(() {
      usecase = AddToWishlist(repository: mockRepository);
    });

    test('should add item to wishlist through repository', () async {
      // Arrange
      final tItem = WishlistItem(
        id: 'ESP',
        name: 'Spain',
        flagUrl: 'https://flagcdn.com/es.svg',
        addedAt: DateTime(2024, 1, 15),
      );

      when(() => mockRepository.addToWishlist(any()))
          .thenAnswer((_) async {});

      // Act
      await usecase(tItem);

      // Assert
      verify(() => mockRepository.addToWishlist(tItem)).called(1);
    });
  });

  group('RemoveFromWishlist', () {
    late RemoveFromWishlist usecase;

    setUp(() {
      usecase = RemoveFromWishlist(repository: mockRepository);
    });

    test('should remove item from wishlist through repository', () async {
      // Arrange
      const tCountryId = 'ESP';

      when(() => mockRepository.removeFromWishlist(tCountryId))
          .thenAnswer((_) async {});

      // Act
      await usecase(tCountryId);

      // Assert
      verify(() => mockRepository.removeFromWishlist(tCountryId)).called(1);
    });
  });

  group('IsInWishlist', () {
    late IsInWishlist usecase;

    setUp(() {
      usecase = IsInWishlist(repository: mockRepository);
    });

    test('should return true when item is in wishlist', () async {
      // Arrange
      const tCountryId = 'ESP';

      when(() => mockRepository.isInWishlist(tCountryId))
          .thenAnswer((_) async => true);

      // Act
      final result = await usecase(tCountryId);

      // Assert
      expect(result, isTrue);
      verify(() => mockRepository.isInWishlist(tCountryId)).called(1);
    });

    test('should return false when item is not in wishlist', () async {
      // Arrange
      const tCountryId = 'ESP';

      when(() => mockRepository.isInWishlist(tCountryId))
          .thenAnswer((_) async => false);

      // Act
      final result = await usecase(tCountryId);

      // Assert
      expect(result, isFalse);
      verify(() => mockRepository.isInWishlist(tCountryId)).called(1);
    });
  });

  group('BatchCheckWishlistStatus', () {
    late BatchCheckWishlistStatus usecase;

    setUp(() {
      usecase = BatchCheckWishlistStatus(repository: mockRepository);
    });

    test('should return status map for multiple countries', () async {
      // Arrange
      final tCountryIds = ['ESP', 'FRA', 'ITA'];
      final tStatus = {
        'ESP': true,
        'FRA': false,
        'ITA': false,
      };

      when(() => mockRepository.batchCheckWishlistStatus(tCountryIds))
          .thenAnswer((_) async => tStatus);

      // Act
      final result = await usecase(tCountryIds);

      // Assert
      expect(result, equals(tStatus));
      expect(result['ESP'], isTrue);
      expect(result['FRA'], isFalse);
      verify(() => mockRepository.batchCheckWishlistStatus(tCountryIds)).called(1);
    });

    test('should return all false for empty wishlist', () async {
      // Arrange
      final tCountryIds = ['ESP', 'FRA'];
      final tStatus = {
        'ESP': false,
        'FRA': false,
      };

      when(() => mockRepository.batchCheckWishlistStatus(tCountryIds))
          .thenAnswer((_) async => tStatus);

      // Act
      final result = await usecase(tCountryIds);

      // Assert
      expect(result['ESP'], isFalse);
      expect(result['FRA'], isFalse);
    });
  });

  group('ClearWishlist', () {
    late ClearWishlist usecase;

    setUp(() {
      usecase = ClearWishlist(repository: mockRepository);
    });

    test('should clear all items through repository', () async {
      // Arrange
      when(() => mockRepository.clearWishlist())
          .thenAnswer((_) async {});

      // Act
      await usecase();

      // Assert
      verify(() => mockRepository.clearWishlist()).called(1);
    });
  });
}
