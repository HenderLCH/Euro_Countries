import 'package:equatable/equatable.dart';
import 'package:euro_list/features/countries/domain/entities/country.dart';

// Estados para el bloc de los detalles por pais

abstract class CountryDetailState extends Equatable {
  const CountryDetailState();

  @override
  List<Object?> get props => [];
}

class CountryDetailInitial extends CountryDetailState {}

class CountryDetailLoading extends CountryDetailState {}

class CountryDetailLoaded extends CountryDetailState {
  const CountryDetailLoaded({
    required this.country,
    required this.isInWishlist,
  });

  final Country country;
  final bool isInWishlist;

  @override
  List<Object?> get props => [country, isInWishlist];

  CountryDetailLoaded copyWith({
    Country? country,
    bool? isInWishlist,
  }) {
    return CountryDetailLoaded(
      country: country ?? this.country,
      isInWishlist: isInWishlist ?? this.isInWishlist,
    );
  }
}

class CountryDetailError extends CountryDetailState {
  const CountryDetailError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
