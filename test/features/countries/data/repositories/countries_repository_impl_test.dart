import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:euro_list/features/countries/data/datasources/restcountries_api.dart';
import 'package:euro_list/features/countries/data/repositories/countries_repository_impl.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';

class MockRestCountriesApi extends Mock implements RestCountriesApi {}

void main() {
  late CountryRepositoryImpl repository;
  late MockRestCountriesApi mockApi;

  setUp(() {
    mockApi = MockRestCountriesApi();
    repository = CountryRepositoryImpl(api: mockApi);
  });

  group('CountryRepositoryImpl', () {
    group('getEuropeanCountries', () {
      test('should return list of countries when API call succeeds', () async {
        // Arrange - Simular respuesta JSON de la API
        final mockApiResponse = [
          {
            'cca3': 'ESP',
            'name': {
              'common': 'Spain',
              'official': 'Kingdom of Spain',
            },
            'capital': ['Madrid'],
            'population': 47000000,
            'region': 'Europe',
            'flags': {
              'png': 'https://flagcdn.com/w320/es.png',
              'svg': 'https://flagcdn.com/es.svg',
            },
            'currencies': {
              'EUR': {
                'name': 'Euro',
                'symbol': '€',
              }
            },
            'languages': {
              'spa': 'Spanish',
            },
            'area': 505992.0,
            'timezones': ['UTC+01:00'],
          },
          {
            'cca3': 'FRA',
            'name': {
              'common': 'France',
              'official': 'French Republic',
            },
            'capital': ['Paris'],
            'population': 67000000,
            'region': 'Europe',
            'flags': {
              'png': 'https://flagcdn.com/w320/fr.png',
              'svg': 'https://flagcdn.com/fr.svg',
            },
            'currencies': {
              'EUR': {
                'name': 'Euro',
                'symbol': '€',
              }
            },
            'languages': {
              'fra': 'French',
            },
            'area': 643801.0,
            'timezones': ['UTC+01:00'],
          },
        ];

        when(() => mockApi.getEuropeanCountries())
            .thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await repository.getEuropeanCountries();

        // Assert
        expect(result, isA<List<Country>>());
        expect(result.length, 2);
        expect(result.first.name, 'Spain');
        expect(result.first.capital, 'Madrid');
        expect(result.first.id, 'ESP');
        expect(result[1].name, 'France');
        verify(() => mockApi.getEuropeanCountries()).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(() => mockApi.getEuropeanCountries())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.getEuropeanCountries(),
          throwsException,
        );
        verify(() => mockApi.getEuropeanCountries()).called(1);
      });

      test('should return empty list when API returns empty list', () async {
        // Arrange
        when(() => mockApi.getEuropeanCountries())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getEuropeanCountries();

        // Assert
        expect(result, isEmpty);
        expect(result, isA<List<Country>>());
        verify(() => mockApi.getEuropeanCountries()).called(1);
      });

      test('should correctly convert API data to Country entities', () async {
        // Arrange
        final mockApiResponse = [
          {
            'cca3': 'ITA',
            'name': {
              'common': 'Italy',
              'official': 'Italian Republic',
            },
            'capital': ['Rome'],
            'population': 59554023,
            'region': 'Europe',
            'flags': {
              'png': 'https://flagcdn.com/w320/it.png',
              'svg': 'https://flagcdn.com/it.svg',
            },
            'currencies': {
              'EUR': {
                'name': 'Euro',
                'symbol': '€',
              }
            },
            'languages': {
              'ita': 'Italian',
            },
            'area': 301340.0,
            'timezones': ['UTC+01:00'],
          },
        ];

        when(() => mockApi.getEuropeanCountries())
            .thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await repository.getEuropeanCountries();

        // Assert
        final country = result.first;
        expect(country.id, 'ITA');
        expect(country.name, 'Italy');
        expect(country.capital, 'Rome');
        expect(country.population, 59554023);
        expect(country.region, 'Europe');
        expect(country.flagUrl, 'https://flagcdn.com/w320/it.png');
        expect(country.currencies, contains('Euro'));
        expect(country.languages, contains('Italian'));
      });
    });

    group('getCountryByName', () {
      test('should return country when API call succeeds', () async {
        // Arrange
        const countryName = 'Spain';
        final mockApiResponse = {
          'cca3': 'ESP',
          'name': {
            'common': 'Spain',
            'official': 'Kingdom of Spain',
          },
          'capital': ['Madrid'],
          'population': 47000000,
          'region': 'Europe',
          'flags': {
            'png': 'https://flagcdn.com/w320/es.png',
            'svg': 'https://flagcdn.com/es.svg',
          },
          'currencies': {
            'EUR': {
              'name': 'Euro',
              'symbol': '€',
            }
          },
          'languages': {
            'spa': 'Spanish',
          },
          'area': 505992.0,
          'timezones': ['UTC+01:00'],
        };

        when(() => mockApi.getCountryByName(countryName))
            .thenAnswer((_) async => mockApiResponse);

        // Act
        final result = await repository.getCountryByName(countryName);

        // Assert
        expect(result, isA<Country>());
        expect(result.name, 'Spain');
        expect(result.capital, 'Madrid');
        expect(result.id, 'ESP');
        verify(() => mockApi.getCountryByName(countryName)).called(1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        const countryName = 'Spain';
        when(() => mockApi.getCountryByName(countryName))
            .thenThrow(Exception('Country not found'));

        // Act & Assert
        expect(
          () => repository.getCountryByName(countryName),
          throwsException,
        );
        verify(() => mockApi.getCountryByName(countryName)).called(1);
      });

      test('should pass correct country name to API', () async {
        // Arrange
        const countryName = 'France';
        final mockApiResponse = {
          'cca3': 'FRA',
          'name': {'common': 'France', 'official': 'French Republic'},
          'capital': ['Paris'],
          'population': 67000000,
          'region': 'Europe',
          'flags': {'png': 'url', 'svg': 'url'},
        };

        when(() => mockApi.getCountryByName(any()))
            .thenAnswer((_) async => mockApiResponse);

        // Act
        await repository.getCountryByName(countryName);

        // Assert
        verify(() => mockApi.getCountryByName(countryName)).called(1);
      });
    });
  });
}
