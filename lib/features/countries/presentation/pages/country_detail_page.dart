import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:euro_list/injection_container.dart' as di;
import 'package:euro_list/features/countries/presentation/bloc/country_detail_cubit.dart';
import 'package:euro_list/features/countries/presentation/bloc/country_detail_state.dart';
import 'package:euro_list/core/widgets/loading_widget.dart';
import 'package:euro_list/core/widgets/error_widget.dart';

class CountryDetailPage extends StatelessWidget {
  const CountryDetailPage({
    super.key,
    required this.countryName,
  });

  final String countryName;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<CountryDetailCubit>()..loadCountryDetail(countryName),
      child: Scaffold(
        appBar: AppBar(
          title: Text(countryName),
          actions: [
            BlocBuilder<CountryDetailCubit, CountryDetailState>(
              builder: (context, state) {
                if (state is CountryDetailLoaded) {
                  return IconButton(
                    icon: Icon(
                      state.isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: state.isInWishlist ? Colors.red : null,
                    ),
                    onPressed: () {
                      context.read<CountryDetailCubit>().toggleWishlist();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<CountryDetailCubit, CountryDetailState>(
          builder: (context, state) {
            if (state is CountryDetailLoading) {
              return const LoadingWidget(message: 'Loading country details...');
            }

            if (state is CountryDetailError) {
              return ErrorDisplayWidget(
                message: state.message,
                onRetry: () => context.read<CountryDetailCubit>().loadCountryDetail(countryName),
              );
            }

            if (state is CountryDetailLoaded) {
              final country = state.country;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 4,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bandera
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                country.flagUrl,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 180),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Título
                          Center(
                            child: Text(
                              country.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Toda la información en un solo bloque
                          _buildInfoRow(context, 'Capital', country.capital),
                          _buildInfoRow(context, 'Region', country.region),
                          _buildInfoRow(context, 'Population', _formatNumber(country.population)),
                          if (country.area != null)
                            _buildInfoRow(context, 'Area', '${_formatNumber(country.area!.toInt())} km²'),
                          if (country.currencies != null)
                            _buildInfoRow(context, 'Currencies', country.currencies!),
                          if (country.languages != null)
                            _buildInfoRow(context, 'Languages', country.languages!),
                          if (country.timezones != null)
                            _buildInfoRow(context, 'Timezones', country.timezones!),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
