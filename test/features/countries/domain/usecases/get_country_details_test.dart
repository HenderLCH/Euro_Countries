import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';
import 'package:euro_list/features/countries/domain/usecases/get_country_details.dart';

class MockCountryRepository extends Mock implements CountryRepository {}

void main() {
  late GetCountryDetails usecase;
  late MockCountryRepository mockRepository;

  setUp(() {
    mockRepository = MockCountryRepository();
    usecase = GetCountryDetails(repository: mockRepository);
  });

  group('GetCountryDetails', () {
    const tCountryName = 'Spain';
    const tCountry = Country(
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

    test('should return country details from repository', () async {
      // Arrange
      when(() => mockRepository.getCountryByName(tCountryName))
          .thenAnswer((_) async => tCountry);

      // Act
      final result = await usecase(tCountryName);

      // Assert
      expect(result, equals(tCountry));
      expect(result.name, 'Spain');
      expect(result.capital, 'Madrid');
      verify(() => mockRepository.getCountryByName(tCountryName)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository throws', () async {
      // Arrange
      final exception = Exception('Country not found');
      when(() => mockRepository.getCountryByName(tCountryName))
          .thenThrow(exception);

      // Act & Assert
      expect(() => usecase(tCountryName), throwsException);
      verify(() => mockRepository.getCountryByName(tCountryName)).called(1);
    });

    test('should pass correct country name to repository', () async {
      // Arrange
      const differentName = 'France';
      const tFrance = Country(
        id: 'FRA',
        name: 'France',
        capital: 'Paris',
        population: 67000000,
        region: 'Europe',
        flagUrl: 'https://flagcdn.com/fr.svg',
      );

      when(() => mockRepository.getCountryByName(differentName))
          .thenAnswer((_) async => tFrance);

      // Act
      await usecase(differentName);

      // Assert
      verify(() => mockRepository.getCountryByName(differentName)).called(1);
      verifyNever(() => mockRepository.getCountryByName(tCountryName));
    });

    test('should handle API errors gracefully', () async {
      // Arrange
      when(() => mockRepository.getCountryByName(tCountryName))
          .thenThrow(Exception('Network timeout'));

      // Act & Assert
      expect(
        () => usecase(tCountryName),
        throwsA(isA<Exception>()),
      );
    });
  });
}
