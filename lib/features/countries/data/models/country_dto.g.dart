// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryDto _$CountryDtoFromJson(Map<String, dynamic> json) => CountryDto(
      id: json['cca3'] as String,
      name: NameDto.fromJson(json['name'] as Map<String, dynamic>),
      capital:
          (json['capital'] as List<dynamic>?)?.map((e) => e as String).toList(),
      currencies: json['currencies'] as Map<String, dynamic>?,
      flags: FlagsDto.fromJson(json['flags'] as Map<String, dynamic>),
      region: json['region'] as String,
      population: (json['population'] as num).toInt(),
      languages: (json['languages'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      area: (json['area'] as num?)?.toDouble(),
      timezones: (json['timezones'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CountryDtoToJson(CountryDto instance) =>
    <String, dynamic>{
      'cca3': instance.id,
      'name': instance.name,
      'capital': instance.capital,
      'currencies': instance.currencies,
      'flags': instance.flags,
      'region': instance.region,
      'population': instance.population,
      'languages': instance.languages,
      'area': instance.area,
      'timezones': instance.timezones,
    };

NameDto _$NameDtoFromJson(Map<String, dynamic> json) => NameDto(
      common: json['common'] as String,
      official: json['official'] as String,
    );

Map<String, dynamic> _$NameDtoToJson(NameDto instance) => <String, dynamic>{
      'common': instance.common,
      'official': instance.official,
    };

FlagsDto _$FlagsDtoFromJson(Map<String, dynamic> json) => FlagsDto(
      png: json['png'] as String,
      svg: json['svg'] as String,
    );

Map<String, dynamic> _$FlagsDtoToJson(FlagsDto instance) => <String, dynamic>{
      'png': instance.png,
      'svg': instance.svg,
    };
