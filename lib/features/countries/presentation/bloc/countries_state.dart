import 'package:equatable/equatable.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';

//Estados para el bloc de loa paises europeos

abstract class CountriesState extends Equatable {
  const CountriesState();

  @override
  List<Object?> get props => [];
}

class CountriesInitial extends CountriesState {}

class CountriesLoading extends CountriesState {}

class CountriesLoaded extends CountriesState {
  const CountriesLoaded({
    required this.countries,
    required this.wishlistStatus,
  });

  final List<Country> countries;
  final Map<String, bool> wishlistStatus;

  @override
  List<Object?> get props => [countries, wishlistStatus];
}

class CountriesError extends CountriesState {
  const CountriesError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}