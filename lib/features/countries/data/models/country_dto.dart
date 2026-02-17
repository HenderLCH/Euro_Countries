import 'package:json_annotation/json_annotation.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';

part 'country_dto.g.dart';

@JsonSerializable()
class CountryDto {
  @JsonKey(name: 'cca3')
  final String id;

  @JsonKey(name: 'name')
  final NameDto name;

  @JsonKey(name: 'capital')
  final List<String>? capital;

  @JsonKey(name: 'currencies')
  final Map<String, dynamic>? currencies;

  @JsonKey(name: 'flags')
  final FlagsDto flags;

  @JsonKey(name: 'region')
  final String region;

  @JsonKey(name: 'population')
  final int population;

  @JsonKey(name: 'languages')
  final Map<String, String>? languages;

  @JsonKey(name: 'area')
  final double? area;

  @JsonKey(name: 'timezones')
  final List<String>? timezones;

  CountryDto(
      {required this.id,
      required this.name,
      this.capital,
      this.currencies,
      required this.flags,
      required this.region,
      required this.population,
      this.languages,
      this.area,
      this.timezones});

  factory CountryDto.fromJson(Map<String, dynamic> json) =>
      _$CountryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CountryDtoToJson(this);

  Country toEntity() {
    return Country(
      id: id,
      name: name.common,
      capital: capital?.isNotEmpty == true ? capital!.first : 'N/A',
      currencies: _formatCurrencies(),
      flagUrl: flags.png,
      region: region,
      population: population,
      languages: _formatLanguages(),
      area: area,
      timezones: timezones?.join(', '),
    );
  }

  String? _formatCurrencies() {
    if (currencies == null || currencies!.isEmpty) return null;

    return currencies!.entries
        .map((e) => '${e.value['name']} (${e.value['symbol'] ?? e.key})')
        .join(', ');
  }

  String? _formatLanguages() {
    if (languages == null || languages!.isEmpty) return null;

    return languages!.values.join(', ');
  }
}

@JsonSerializable()
class NameDto {
  final String common;
  final String official;

  const NameDto({required this.common, required this.official});

  factory NameDto.fromJson(Map<String, dynamic> json) =>
      _$NameDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NameDtoToJson(this);
}

@JsonSerializable()
class FlagsDto {
  final String png;
  final String svg;

  const FlagsDto({required this.png, required this.svg});

  factory FlagsDto.fromJson(Map<String, dynamic> json) =>
      _$FlagsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FlagsDtoToJson(this);
}
