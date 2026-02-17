import 'package:euro_list/features/countries/data/datasources/restcountries_api.dart';
import 'package:euro_list/features/countries/data/models/country_dto.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';

class CountryRepositoryImpl implements CountryRepository {

  final RestCountriesApi api;

  CountryRepositoryImpl({required this.api});

  @override
  Future<List<Country>> getEuropeanCountries() async {
   
    final data = await api.getEuropeanCountries();
    return data.map((json) => CountryDto.fromJson(json).toEntity()).toList();

  }

  @override
  Future<Country> getCountryByName(String name) async {

    final data = await api.getCountryByName(name);
    return CountryDto.fromJson(data).toEntity();
    
  }
  
}