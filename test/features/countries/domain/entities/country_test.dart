import 'package:flutter_test/flutter_test.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';

void main() {
  group('Country Entity', () {
    test('should create country instance with all properties', () {
      // Arrange & Act
      const country = Country(
        id: 'ESP',
        name: 'Spain',
        capital: 'Madrid',
        population: 47000000,
        region: 'Europe',
        flagUrl: 'https://flagcdn.com/es.svg',
        currencies: 'Euro (EUR)',
        languages: 'Spanish',
        area: 505992.0,
        timezones: 'UTC+01:00',
      );

      // Assert
      expect(country.id, 'ESP');
      expect(country.name, 'Spain');
      expect(country.capital, 'Madrid');
      expect(country.population, 47000000);
      expect(country.region, 'Europe');
      expect(country.flagUrl, 'https://flagcdn.com/es.svg');
      expect(country.currencies, 'Euro (EUR)');
      expect(country.languages, 'Spanish');
      expect(country.area, 505992.0);
      expect(country.timezones, 'UTC+01:00');
    });

    test('should support equality comparison with Equatable', () {
      // Arrange
      const country1 = Country(
        id: 'ESP',
        name: 'Spain',
        capital: 'Madrid',
        population: 47000000,
        region: 'Europe',
        flagUrl: 'https://flagcdn.com/es.svg',
      );

      const country2 = Country(
        id: 'ESP',
        name: 'Spain',
        capital: 'Madrid',
        population: 47000000,
        region: 'Europe',
        flagUrl: 'https://flagcdn.com/es.svg',
      );

      const country3 = Country(
        id: 'FRA',
        name: 'France',
        capital: 'Paris',
        population: 67000000,
        region: 'Europe',
        flagUrl: 'https://flagcdn.com/fr.svg',
      );

      // Assert
      expect(country1, equals(country2));
      expect(country1.hashCode, equals(country2.hashCode));
      expect(country1, isNot(equals(country3)));
    });

    test('should create country with optional null fields', () {
      // Arrange & Act
      const country = Country(
        id: 'XYZ',
        name: 'Unknown',
        capital: 'N/A',
        population: 0,
        region: 'Unknown',
        flagUrl: 'https://example.com/flag.png',
        currencies: null,
        languages: null,
        area: null,
        timezones: null,
      );

      // Assert
      expect(country.currencies, isNull);
      expect(country.languages, isNull);
      expect(country.area, isNull);
      expect(country.timezones, isNull);
    });

    test('should include all properties in equality comparison', () {
      // Arrange
      const country1 = Country(
        id: 'ESP',
        name: 'Spain',
        capital: 'Madrid',
        population: 47000000,
        region: 'Europe',
        flagUrl: 'https://flagcdn.com/es.svg',
        currencies: 'Euro',
      );

      const country2 = Country(
        id: 'ESP',
        name: 'Spain',
        capital: 'Madrid',
        population: 47000000,
        region: 'Europe',
        flagUrl: 'https://flagcdn.com/es.svg',
        currencies: 'Dollar', // Diferente
      );

      // Assert
      expect(country1, isNot(equals(country2)));
    });
  });
}
