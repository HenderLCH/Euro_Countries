import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';

class GetCountryDetails {

      const GetCountryDetails({required this.repository});

      final CountryRepository repository;

      Future<Country> call(String name) async {

        return await repository.getCountryByName(name);
      
      }
      
}