import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';
import 'package:euro_list/features/countries/domain/usecases/get_european_countries.dart';

class MockCountryRepository extends Mock implements CountryRepository {}

void main() {
  late GetEuropeanCountries usecase;
  late MockCountryRepository mockRepository;

  setUp(() {
    mockRepository = MockCountryRepository();
    usecase = GetEuropeanCountries(repository: mockRepository);
  });

  group('GetEuropeanCountries', () {
    final tCountries = [
      const Country(
        id: 'ESP',
        name: 'Spain',
        capital: 'Madrid',
        population: 47000000,
        region: 'Europe',
        flagUrl: 'https://flagcdn.com/es.svg',
      ),
      const Country(
        id: 'FRA',
        name: 'France',
        capital: 'Paris',
        population: 67000000,
        region: 'Europe',
        flagUrl: 'https://flagcdn.com/fr.svg',
      ),
    ];

    test('should return list of countries from repository', () async {
      // Arrange
      when(() => mockRepository.getEuropeanCountries())
          .thenAnswer((_) async => tCountries);

      // Act
      final result = await usecase();

      // Assert
      expect(result, equals(tCountries));
      expect(result.length, 2);
      expect(result.first.name, 'Spain');
      verify(() => mockRepository.getEuropeanCountries()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository throws', () async {
      // Arrange
      final exception = Exception('Network error');
      when(() => mockRepository.getEuropeanCountries()).thenThrow(exception);

      // Act & Assert
      expect(() => usecase(), throwsException);
      verify(() => mockRepository.getEuropeanCountries()).called(1);
    });

    test('should return empty list when repository returns empty list', () async {
      // Arrange
      when(() => mockRepository.getEuropeanCountries())
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase();

      // Assert
      expect(result, isEmpty);
      expect(result, isA<List<Country>>());
      verify(() => mockRepository.getEuropeanCountries()).called(1);
    });

    test('should call repository method exactly once', () async {
      // Arrange
      when(() => mockRepository.getEuropeanCountries())
          .thenAnswer((_) async => tCountries);

      // Act
      await usecase();

      // Assert
      verify(() => mockRepository.getEuropeanCountries()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
