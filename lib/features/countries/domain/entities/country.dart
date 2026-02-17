import 'package:equatable/equatable.dart';

//Entidad para pais

class Country extends Equatable {
  const Country({

    required this.id,
    required this.name,
    required this.capital,
    required this.population,
    required this.region,
    required this.flagUrl,
    this.currencies,
    this.languages,
    this.area,
    this.timezones,
    
  });

  final String id;
  final String name;
  final String capital;
  final int population;
  final String region;
  final String flagUrl;
  final String? currencies;
  final String? languages;
  final double? area;
  final String? timezones;

  @override
  List<Object?> get props => [
        id,
        name,
        capital,
        population,
        region,
        flagUrl,
        currencies,
        languages,
        area,
        timezones
      ];
}
