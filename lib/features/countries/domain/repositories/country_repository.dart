import 'package:euro_list/features/countries/domain/entities/country.dart';

abstract class CountryRepository {

  Future<List<Country>> getEuropeanCountries();
  Future<Country> getCountryByName(String name);
  
}