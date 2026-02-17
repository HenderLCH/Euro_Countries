import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';
import 'package:euro_list/features/countries/domain/usecases/get_european_countries.dart';

// 1. Crear mock del repository
class MockCountryRepository extends Mock implements CountryRepository {}

void main() {
  late GetEuropeanCountries usecase;
  late MockCountryRepository mockRepository;

  setUp(() {
    mockRepository = MockCountryRepository();
    usecase = GetEuropeanCountries(repository: mockRepository);
  });

  group('GetEuropeanCountries', () {
    // TEST 1: Caso de éxito
    test('should return list of countries from repository', () async {
      // Arrange (preparar)
      // TODO: Crear lista de países de prueba
      final tCountries = [
        const Country(
          id: 'ESP',
          name: 'Spain',
          capital: 'Madrid',
          // ... resto de propiedades
        ),
      ];
      
      // TODO: Mockear la llamada al repository
      when(() => mockRepository.getEuropeanCountries())
          .thenAnswer((_) async => tCountries);

      // Act (ejecutar)
      // TODO: Llamar al use case
      final result = await usecase();

      // Assert (verificar)
      // TODO: Verificar que retorna la lista correcta
      expect(result, tCountries);
      verify(() => mockRepository.getEuropeanCountries()).called(1);
    });

    // TEST 2: Caso de error
    test('should throw exception when repository throws', () async {
      // TODO: Mockear que el repository lanza error
      when(() => mockRepository.getEuropeanCountries())
          .thenThrow(Exception('Network error'));

      // TODO: Verificar que el use case lanza excepción
      expect(() => usecase(), throwsException);
    });

    // TEST 3: Lista vacía
    test('should return empty list when repository returns empty', () async {
      // TODO: Mockear que retorna lista vacía
      // TODO: Verificar que retorna lista vacía
    });
  });
}