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
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bandera
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          country.flagUrl,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Información básica
                    _buildInfoCard(context, 'Basic Information', [
                      _InfoRow(label: 'Official Name', value: country.name),
                      _InfoRow(label: 'Capital', value: country.capital),
                      _InfoRow(label: 'Region', value: country.region),
                      _InfoRow(label: 'Population', value: _formatNumber(country.population)),
                    ]),

                    const SizedBox(height: 16),

                    // Información adicional
                    if (country.currencies != null || country.languages != null || country.area != null)
                      _buildInfoCard(context, 'Additional Information', [
                        if (country.currencies != null)
                          _InfoRow(label: 'Currencies', value: country.currencies!),
                        if (country.languages != null)
                          _InfoRow(label: 'Languages', value: country.languages!),
                        if (country.area != null)
                          _InfoRow(label: 'Area', value: '${_formatNumber(country.area!.toInt())} km²'),
                        if (country.timezones != null)
                          _InfoRow(label: 'Timezones', value: country.timezones!),
                      ]),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<_InfoRow> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...rows.map((row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
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

class _InfoRow {
  final String label;
  final String value;

  _InfoRow({required this.label, required this.value});
}
