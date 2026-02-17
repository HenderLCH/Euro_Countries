import 'package:flutter_test/flutter_test.dart';
import 'package:euro_list/features/wishlist/domain/entities/wishlist_item.dart';

void main() {
  group('WishlistItem Entity', () {
    test('should create wishlist item instance with all properties', () {
      // Arrange
      final addedAt = DateTime(2024, 1, 15);
      
      // Act
      final wishlistItem = WishlistItem(
        id: 'ESP',
        name: 'Spain',
        flagUrl: 'https://flagcdn.com/es.svg',
        addedAt: addedAt,
      );

      // Assert
      expect(wishlistItem.id, 'ESP');
      expect(wishlistItem.name, 'Spain');
      expect(wishlistItem.flagUrl, 'https://flagcdn.com/es.svg');
      expect(wishlistItem.addedAt, addedAt);
    });

    test('should support equality comparison with Equatable', () {
      // Arrange
      final addedAt = DateTime(2024, 1, 15);
      
      final wishlistItem1 = WishlistItem(
        id: 'ESP',
        name: 'Spain',
        flagUrl: 'https://flagcdn.com/es.svg',
        addedAt: addedAt,
      );

      final wishlistItem2 = WishlistItem(
        id: 'ESP',
        name: 'Spain',
        flagUrl: 'https://flagcdn.com/es.svg',
        addedAt: addedAt,
      );

      final wishlistItem3 = WishlistItem(
        id: 'FRA',
        name: 'France',
        flagUrl: 'https://flagcdn.com/fr.svg',
        addedAt: addedAt,
      );

      // Assert
      expect(wishlistItem1, equals(wishlistItem2));
      expect(wishlistItem1.hashCode, equals(wishlistItem2.hashCode));
      expect(wishlistItem1, isNot(equals(wishlistItem3)));
    });

    test('should differentiate items with different dates', () {
      // Arrange
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 1, 16);

      final item1 = WishlistItem(
        id: 'ESP',
        name: 'Spain',
        flagUrl: 'https://flagcdn.com/es.svg',
        addedAt: date1,
      );

      final item2 = WishlistItem(
        id: 'ESP',
        name: 'Spain',
        flagUrl: 'https://flagcdn.com/es.svg',
        addedAt: date2, // Fecha diferente
      );

      // Assert
      expect(item1, isNot(equals(item2)));
    });

    test('should include all properties in equality comparison', () {
      // Arrange
      final addedAt = DateTime(2024, 1, 15);

      final item1 = WishlistItem(
        id: 'ESP',
        name: 'Spain',
        flagUrl: 'https://flagcdn.com/es.svg',
        addedAt: addedAt,
      );

      final item2 = WishlistItem(
        id: 'ESP',
        name: 'España', // Nombre diferente
        flagUrl: 'https://flagcdn.com/es.svg',
        addedAt: addedAt,
      );

      // Assert
      expect(item1, isNot(equals(item2)));
    });
  });
}
