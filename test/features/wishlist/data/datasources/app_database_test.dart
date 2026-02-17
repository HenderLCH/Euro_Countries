import 'package:flutter_test/flutter_test.dart';
import 'package:euro_list/features/wishlist/data/datasources/app_database.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Crear base de datos en memoria para tests
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('AppDatabase - Wishlist CRUD Operations', () {
    final tWishlistItem = WishlistItemData(
      id: 'ESP',
      name: 'Spain',
      flagUrl: 'https://flagcdn.com/w320/es.png',
      addedAt: DateTime(2024, 1, 1),
    );

    final tWishlistItem2 = WishlistItemData(
      id: 'FRA',
      name: 'France',
      flagUrl: 'https://flagcdn.com/w320/fr.png',
      addedAt: DateTime(2024, 1, 2),
    );

    group('addToWishlist - Success Cases', () {
      test('should add item to empty wishlist successfully', () async {
        // Act
        await database.addToWishlist(tWishlistItem);

        // Assert
        final items = await database.getAllWishlistItems();
        expect(items, hasLength(1));
        expect(items.first.id, tWishlistItem.id);
        expect(items.first.name, tWishlistItem.name);
        expect(items.first.flagUrl, tWishlistItem.flagUrl);
      });

      test('should update existing item when adding with same ID', () async {
        // Arrange
        await database.addToWishlist(tWishlistItem);

        // Act - Agregar mismo item con nombre diferente
        final updatedItem = WishlistItemData(
          id: 'ESP',
          name: 'España', // Nombre actualizado
          flagUrl: 'https://flagcdn.com/w320/es.png',
          addedAt: DateTime(2024, 1, 3),
        );
        await database.addToWishlist(updatedItem);

        // Assert
        final items = await database.getAllWishlistItems();
        expect(items, hasLength(1), reason: 'Should only have 1 item (updated)');
        expect(items.first.name, 'España', reason: 'Name should be updated');
      });
    });

    group('getAllWishlistItems - Success Cases', () {
      test('should return empty list when wishlist is empty', () async {
        // Act
        final items = await database.getAllWishlistItems();

        // Assert
        expect(items, isEmpty, reason: 'Empty wishlist should return empty list');
      });

      test('should return all items in wishlist', () async {
        // Arrange
        await database.addToWishlist(tWishlistItem);
        await database.addToWishlist(tWishlistItem2);

        // Act
        final items = await database.getAllWishlistItems();

        // Assert
        expect(items, hasLength(2), reason: 'Should return both items');
        expect(items.map((e) => e.id).toList(), containsAll(['ESP', 'FRA']));
      });
    });

    group('removeFromWishlist - Success Cases', () {
      test('should remove existing item from wishlist', () async {
        // Arrange
        await database.addToWishlist(tWishlistItem);
        await database.addToWishlist(tWishlistItem2);

        // Act
        await database.removeFromWishlist('ESP');

        // Assert
        final items = await database.getAllWishlistItems();
        expect(items, hasLength(1), reason: 'Should have 1 item remaining');
        expect(items.first.id, 'FRA', reason: 'Only France should remain');
      });

      test('should handle removing non-existent item gracefully', () async {
        // Arrange
        await database.addToWishlist(tWishlistItem);

        // Act & Assert - No debería lanzar error
        await database.removeFromWishlist('NON_EXISTENT');
        
        final items = await database.getAllWishlistItems();
        expect(items, hasLength(1), reason: 'Original item should still be there');
      });
    });

    group('isInWishlist - Success Cases', () {
      test('should return true when item exists in wishlist', () async {
        // Arrange
        await database.addToWishlist(tWishlistItem);

        // Act
        final result = await database.isInWishlist('ESP');

        // Assert
        expect(result, isTrue, reason: 'Spain should be in wishlist');
      });

      test('should return false when item does not exist in wishlist', () async {
        // Act
        final result = await database.isInWishlist('ESP');

        // Assert
        expect(result, isFalse, reason: 'Spain should not be in empty wishlist');
      });
    });

    group('clearWishlist - Success Cases', () {
      test('should remove all items from wishlist', () async {
        // Arrange - Agregar varios items
        await database.addToWishlist(tWishlistItem);
        await database.addToWishlist(tWishlistItem2);

        // Act
        await database.clearWishlist();

        // Assert
        final items = await database.getAllWishlistItems();
        expect(items, isEmpty, reason: 'Wishlist should be empty after clear');
      });

      test('should handle clearing empty wishlist', () async {
        // Act & Assert - No debería lanzar error
        await database.clearWishlist();
        
        final items = await database.getAllWishlistItems();
        expect(items, isEmpty);
      });
    });

    group('getWishlistCount - Success Cases', () {
      test('should return 0 for empty wishlist', () async {
        // Act
        final count = await database.getWishlistCount();

        // Assert
        expect(count, 0, reason: 'Empty wishlist should have count 0');
      });

      test('should return correct count of items', () async {
        // Arrange
        await database.addToWishlist(tWishlistItem);
        await database.addToWishlist(tWishlistItem2);

        // Act
        final count = await database.getWishlistCount();

        // Assert
        expect(count, 2, reason: 'Should count both items');
      });
    });

    group('batchCheckWishlistStatus - Success Cases', () {
      test('should return correct status for multiple countries', () async {
        // Arrange
        await database.addToWishlist(tWishlistItem); // Solo España

        // Act
        final status = await database.batchCheckWishlistStatus(['ESP', 'FRA', 'ITA']);

        // Assert
        expect(status, {
          'ESP': true,  // En wishlist
          'FRA': false, // No en wishlist
          'ITA': false, // No en wishlist
        });
      });

      test('should return all false for empty wishlist', () async {
        // Act
        final status = await database.batchCheckWishlistStatus(['ESP', 'FRA']);

        // Assert
        expect(status, {
          'ESP': false,
          'FRA': false,
        });
      });
    });

    group('batchInsertWishlistItems - Success Cases (Performance Test)', () {
      test('should insert multiple items efficiently', () async {
        // Arrange - Crear 50 items
        final items = List.generate(
          50,
          (index) => WishlistItemData(
            id: 'COUNTRY_$index',
            name: 'Country $index',
            flagUrl: 'https://flagcdn.com/w320/country$index.png',
            addedAt: DateTime.now(),
          ),
        );

        // Act
        final stopwatch = Stopwatch()..start();
        await database.batchInsertWishlistItems(items);
        stopwatch.stop();

        // Assert
        final allItems = await database.getAllWishlistItems();
        expect(allItems, hasLength(50), reason: 'All items should be inserted');
        expect(stopwatch.elapsedMilliseconds, lessThan(1000), 
          reason: 'Batch insert should be fast (< 1 second)');
      });

      test('should handle duplicate items in batch insert', () async {
        // Arrange - Agregar un item existente
        await database.addToWishlist(tWishlistItem);
        
        final items = [
          tWishlistItem, // Duplicado
          tWishlistItem2, // Nuevo
        ];

        // Act
        await database.batchInsertWishlistItems(items);

        // Assert
        final allItems = await database.getAllWishlistItems();
        expect(allItems, hasLength(2), reason: 'Should have 2 unique items');
      });
    });
  });
}
