import 'package:euro_list/features/countries/domain/entities/country.dart';
import 'package:euro_list/features/countries/domain/repositories/country_repository.dart';

class GetEuropeanCountries {

  const GetEuropeanCountries({required this.repository});

  final CountryRepository repository;

  Future<List<Country>> call() async {

    return await repository.getEuropeanCountries();
  
  }

}